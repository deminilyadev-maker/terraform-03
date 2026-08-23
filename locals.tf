locals {
  ssh_public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))

  metadata = merge(
    var.metadata["common"],
    {
      ssh-keys = "ubuntu:${local.ssh_public_key}"
    }
  )
}