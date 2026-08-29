resource "incus_instance" "master-node" {
  count = var.k3s_master_count
  name  = "k3s-master"
  image = var.golden_image
  type  = "virtual-machine"

  config = {
    "boot.autostart" = true
    "limits.cpu"     = var.k3s_master_cpu
    "limits.memory"  = var.k3s_master_memory
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "incus"
      size = var.k3s_master_storage
    }
  }

  wait_for {
    type = "agent"
  }
}

resource "incus_instance" "worker-node" {
  count = var.k3s_worker_count
 
  name  = "k3s-worker-${count.index}"
  image = var.golden_image
  type  = "virtual-machine"

  config = {
    "boot.autostart" = true
    "limits.cpu"     = var.k3s_worker_cpu
    "limits.memory"  = var.k3s_worker_memory
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "incus"
      size = var.k3s_worker_storage
    }
  }

  wait_for {
    type = "agent"
  }
}