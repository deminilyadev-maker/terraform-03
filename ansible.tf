variable "web_provision" {
  type        = bool
  default     = true
  description = "ansible provision switch variable"
}


# Создание inventory для Ansible
resource "local_file" "hosts_templatefile" {

  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = yandex_compute_instance.vm_web
    databases  = yandex_compute_instance.each_vm
    storage    = [yandex_compute_instance.storage]
  })

  filename = "${abspath(path.module)}/for.ini"
}


resource "terraform_data" "web_hosts_provision" {

  count = var.web_provision == true ? 1 : 0

  # Ждем создания инстансов и inventory
  depends_on = [
    yandex_compute_instance.vm_web,
    yandex_compute_instance.each_vm,
    yandex_compute_instance.storage,
    local_file.hosts_templatefile
  ]

  # Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command    = "eval $(ssh-agent) && cat ~/.ssh/id_ed25519 | ssh-add -"
    on_failure = continue
  }

  # Костыль!!! Даем ВМ 60 сек на первый запуск.
  # Лучше выполнить это через wait_for port 22 на стороне ansible.
  # В случае использования cloud-init может потребоваться еще больше времени
  #
  # provisioner "local-exec" {
  #   command = "sleep 60"
  # }

  # Запуск ansible-playbook
  provisioner "local-exec" {

    # without secrets
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${abspath(path.module)}/for.ini ${abspath(path.module)}/test.yml"

    # secrets pass
    # > nonsensitive(jsonencode({for k,v in random_password.each: k=>v.result}))
    /*
      "{\"netology-develop-platform-web-0\":\"u(qzeC#nKjp*wTOY\",\"netology-develop-platform-web-1\":\"=pA12\\u0026C2eCl[Oe$9\"}"
    */

    # command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${abspath(path.module)}/for.ini ${abspath(path.module)}/test.yml --extra-vars '{\"secrets\": ${jsonencode({ for k, v in random_password.each : k => v.result })} }'"

    # for complex cases instead --extra-vars "key=value",
    # use --extra-vars "@some_file.json"

    on_failure = continue

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  # Срабатывание пересоздания при изменении значений
  # (аналог triggers у null_resource)
  triggers_replace = {}
}