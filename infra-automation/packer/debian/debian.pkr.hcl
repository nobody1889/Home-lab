packer {
  required_version = ">= 1.9.0"

  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "debian_version" {
  type    = string
  default = "13.6.0"
}

variable "debian_codename" {
  type    = string
  default = "bookworm"
}

variable "image_name" {
  type    = string
  default = "debian-k3s-golden"
}

variable "memory" {
  type    = number
  default = 2048
}

variable "cpus" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "ssh_username" {
  type    = string
  default = "debian"
}

variable "ssh_password" {
  type    = string
  default = "debian"
  sensitive = true
}

variable "k3s_version" {
  type    = string
  default = "v1.31.3+k3s1"
}

variable "disable_components" {
  type    = string
  default = "traefik,servicelb,local-storage,metrics-server"
}

source "qemu" "debian" {
  iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso"
  iso_checksum = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"

  output_directory = "output-${var.image_name}"
  disk_size        = var.disk_size
  format           = "qcow2"
  accelerator      = "kvm"
  headless         = true

  memory = var.memory
  cpus   = var.cpus

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "45m"

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"

  http_directory = "http"

  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg priority=critical<wait>",
    " debian-installer/locale=en_US.UTF-8<wait>",
    " keyboard-configuration/xkb-keymap=us<wait>",
    " netcfg/get_hostname=debian-k3s<wait>",
    " netcfg/get_domain=local<wait>",
    "<enter>"
  ]
}

build {
  name    = "debian-k3s"
  sources = ["source.qemu.debian"]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "K3S_VERSION=${var.k3s_version}",
      "DISABLE_COMPONENTS=${var.disable_components}",
      "SSH_USERNAME=${var.ssh_username}",
      "SSH_PASSWORD=${var.ssh_password}"
    ]

    scripts = [
      "scripts/base_setup.sh",
      "scripts/docker_setup.sh",
      "scripts/k3s_setup.sh",
      "scripts/cleanup.sh"
    ]

    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
  }

  post-processor "shell-local" {
    inline = [
      "echo '=== Converting qcow2 to raw ==='",
      "qemu-img convert -f qcow2 -O raw {{ .BuildOutput }} /tmp/debian-k3s-rootfs.img",

      "echo '=== Creating metadata ==='",
      "mkdir -p /tmp/incus-image",
      "cat > /tmp/incus-image/metadata.yaml <<EOF\narchitecture: x86_64\ncreation_date: $(date +%s)\nproperties:\n  description: \"Debian 12 golden image with k3s (disabled)\"\n  os: Debian\n  release: bookworm\n  variant: cloud\n  serial: $(date +%Y%m%d_%H%M)\nEOF",

      "echo '=== Importing into Incus ==='",
      "incus image import /tmp/incus-image/metadata.yaml /tmp/debian-k3s-rootfs.img --alias debian-k3s-golden --reuse",

      "echo '=== Cleaning temporary files ==='",
      "rm -f /tmp/debian-k3s-rootfs.img",
      "rm -rf /tmp/incus-image",

      "echo '=== Done! Image debian-k3s-golden is ready ==='",
      "incus image list | grep debian-k3s-golden"
    ]
  }
}