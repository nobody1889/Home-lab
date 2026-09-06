packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "debian_version" {
  type    = string
  default = "12"
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
  type = number
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
}

source "qemu" "debian" {
  iso_url          = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${var.debian_version}.*.*-amd64-netinst.iso"
  iso_checksum     = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
  output_directory = "output-${var.image_name}"
  disk_size        = var.disk_size
  memory           = var.memory
  cpus             = var.cpus
  format           = "qcow2"
  accelerator      = "kvm"
  headless         = true
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password     # temporary; will be locked later
  ssh_timeout      = "30m"
  shutdown_command = "echo 'debian' | sudo -S shutdown -P now"

  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "debian-installer/locale=en_US ",
    "keyboard-configuration/xkb-keymap=us ",
    "netcfg/get_hostname=debian-k3s ",
    "netcfg/get_domain=local ",
    "<enter>"
  ]

  http_directory = "http"
}

build {
  name   = "debian-k3s"
  sources = ["source.qemu.debian"]

  provisioner "shell" {
    script = "${path.cwd}/packer/scripts/setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/packer/scripts/docker_setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/packer/scripts/k3s_setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/packer/scripts/cleanup.sh"
  }

}