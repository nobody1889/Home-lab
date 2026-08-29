variable "gitea" {
  type        = string
  default     = "1"
  description = "CPU for gitea container"
  
}

variable "gitea_memory" {
  type        = string
  default     = "4GB"
  description = "Memory for gitea container"
  
}

variable "gitea_storage" {
  type        = string
  default     = "10GB"
  description = "Volume for gitea container"
  
}

variable "k3s_master" {
  type        = string
  default     = "1"
  description = "CPU for k3s master container"

}

variable "k3s_master_memory" {
  type        = string
  default     = "4GB"
  description = "Memory for k3s master container"
  
}

variable "k3s_master_storage" {
  type        = string
  default     = "20GB"
  description = "Volume for k3s master container"
  
}

variable "k3s_worker" {
  type        = string
  default     = "1"
  description = "CPU for k3s worker container"

}

variable "k3s_worker_memory" {
  type        = string
  default     = "4GB"
  description = "Memory for k3s worker container"
  
}

variable "k3s_worker_storage" {
  type        = string
  default     = "20GB"
  description = "Volume for k3s worker container"
  
}