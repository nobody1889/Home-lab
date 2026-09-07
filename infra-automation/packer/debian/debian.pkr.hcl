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
  default = "trixie"
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
  iso_checksum = "file:https://cdimage.debian.org/debian-cd/${var.debian_version}/amd64/iso-cd/SHA256SUMS"
  vm_name = var.image_name

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
    # to publish a version of incus instanse
    script = "${path.cwd}/publish/to-incus.sh"
  }

}