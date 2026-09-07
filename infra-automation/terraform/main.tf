resource "incus_network" "k3s_net" {
  name = "k3s-net"

  config = {
    "ipv4.address" = "10.100.0.1/24"
    "ipv4.nat"     = "true"
    "ipv4.dhcp"    = "true"
    "ipv6.address" = "none"
  }
}

resource "incus_instance" "master-node" {
  count = var.k3s_master_count

  name  = "k3s-master-${count.index}"
  image = var.golden_image
  type  = "virtual-machine"

  config = {
    "boot.autostart" = true
    "limits.cpu"     = var.k3s_master_cpu
    "limits.memory"  = var.k3s_master_memory
    "cloud-init.user-data" = templatefile("${path.module}/cloud-init/master-node.yml",
     {
      ssh_keys = var.master_ssh_public_keys
     }
     )
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = incus_network.k3s_net.name
      "ipv4.address" = cidrhost("10.100.0.0/24", 20 + count.index)
    }
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
    "cloud-init.user-data" = templatefile("${path.module}/cloud-init/worker-node.yml"
    , {
      ssh_keys = var.worker_ssh_public_keys
    })
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network        = incus_network.k3s_net.name
      "ipv4.address" = cidrhost("10.100.0.0/24", 100 + count.index)
    }
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