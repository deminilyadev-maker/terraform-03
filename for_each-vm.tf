variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
    core_fraction = number
    preemptible   = bool
  }))

  default = [
    {
      vm_name     = "main"
      cpu         = 2
      ram         = 4
      disk_volume = 20
      core_fraction = 20
      preemptible   = true
    },
    {
      vm_name     = "replica"
      cpu         = 4
      ram         = 8
      disk_volume = 30
      core_fraction = 20
      preemptible   = true
    }
  ]
}

resource "yandex_compute_instance" "each_vm" {
  for_each = {
    for vm in var.each_vm : vm.vm_name => vm
  }

  name = each.value.vm_name

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
}