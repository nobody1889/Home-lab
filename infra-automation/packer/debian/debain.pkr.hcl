packer {
  required_plugins {
    incus = {
      source  = "github.com/bketelsen/incus"
      version = "~> 1"
    }
  }
}

variable "incus_image_name" {
    type    = string
    default = "base-as-debian"
    description = "Name of the golden image"
}

source "incus" "debian" {
    image = "images:debian:13"
    output_name = var.incus_image_name
}

build {
    name    = "devops-base-image"
    sources = [
        "source.incus.debian"
        ]
    
    # update/upgrade and install base packages
    provisioner "shell" {
        script = "${path.root}/scripts/base.sh"
    }


    provisioner "shell" {
        script = "${path.root}/scripts/docker_setup.sh"
    }

    provisioner "shell" {
        script = "${path.root}/scripts/k3s_setup.sh"
    }

    # cleanup
    provisioner "shell" {
        script = "${path.root}/scripts/cleanup.sh"
    }

}

