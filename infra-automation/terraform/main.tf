resource "incus_instance" "master-node" {
    name = "k3s-master"
    image = "images:base-as-debian"
    type = "virtual-machine"

    config = {
        "boot.autostart" = true
        "limits.cpu"     = var.k3s_master
        "limits.memory"  = var.k3s_master_memory
        "rootfs.size"    = var.k3s_master_storage
    }
}

resource "incus_instance" "worker-node" {
    name = "k3s-worker"
    image = "images:base-as-debian"
    type = "virtual-machine"

    config = {
        "boot.autostart" = true
        "limits.cpu"     = var.k3s_worker
        "limits.memory"  = var.k3s_worker_memory
        "rootfs.size"    = var.k3s_worker_storage
    }
}

