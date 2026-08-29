packer {
  required_plugins {
    incus = {
      source  = "github.com/bketelsen/incus"
      version = "~> 1"
    }
  }
}

variable "incus_image_name" {
  type        = string
  default     = "base-as-debian-vm-2"
  description = "Name of the golden image for VMs"
}

source "incus" "debian" {
  image = "images:debian/12/cloud"
  output_image     = var.incus_image_name
  virtual_machine = true 
}

build {
  name    = "devops-base-image"
  sources = [
    "source.incus.debian"
  ]

  provisioner "shell" {
    script = "${path.cwd}/scripts/base_setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/scripts/docker_setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/scripts/k3s_setup.sh"
  }

  provisioner "shell" {
    script = "${path.cwd}/scripts/cleanup.sh"
  }
}