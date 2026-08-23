resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}
resource "yandex_compute_instance" "vm_web" {
  count       = 2
  name        = "${var.vm_web.name}-${count.index + 1}"
  platform_id = var.vm_web.platform_id

  resources {
    cores         = var.vm_web.cores
    memory        = var.vm_web.memory
    core_fraction = var.vm_web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web.nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.metadata
    depends_on = [
    yandex_compute_instance.each_vm
  ]
}
resource "yandex_compute_instance" "storage" {
  name = "storage"

  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.storage

    content {
      disk_id = secondary_disk.value.id
    }
  }
}