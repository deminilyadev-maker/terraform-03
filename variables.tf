###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  default     = "b1guusj3le769ktnpdvk"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  default     = "b1gp1cf6qghasc85hk1g"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vm_web" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
    preemptible   = bool
    nat           = bool
  })

  default = {
    name          = "vm_web"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 1
    core_fraction = 20
    preemptible   = true
    nat           = true
  }
}

variable "metadata" {
  type = map(object({
    serial-port-enable = number
  }))

  default = {
    common = {
      serial-port-enable = 1
    }
  }
}

variable "vm_web_image_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Family image title"
}

resource "yandex_compute_disk" "storage" {
  count = 3
  name = "storage-${count.index + 1}"
  type = "network-hdd"
  size = 1
}