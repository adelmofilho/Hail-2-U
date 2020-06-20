/*
*   DigitalOcean Provider 
*   https://www.terraform.io/docs/providers/do/index.html
*/

provider "digitalocean" {
  token = "${var.token}"
  api_endpoint = "${var.api_endpoint}"
}

/*
*   digitalocean_ssh_key Resource
*   https://www.terraform.io/docs/providers/do/d/ssh_key.html
*/

resource "digitalocean_ssh_key" "ssh_key" {
  name       = "${var.ssh_key_name}"
  public_key = file("${var.ssh_public_key}")
}

/*
*   digitalocean_droplet Resource 
*   https://www.terraform.io/docs/providers/do/index.html
*/

resource "digitalocean_droplet" "droplet" {
  image    = "${var.image_list[var.image_index]}"
  name     = "${var.droplet_name}"
  region   = "${var.region_list[var.region_index]}"
  size     = "${var.size_list[var.size_index]}"
  ssh_keys = [digitalocean_ssh_key.ssh_key.fingerprint]

  tags = "${var.tags}"
  backups = "${var.backups}"
  monitoring = "${var.monitoring}"
  ipv6 = "${var.ipv6}"
  private_networking = "${var.private_networking}"
  resize_disk = "${var.resize_disk}"

  /*
  *   Provisioner Connection
  *   https://www.terraform.io/docs/provisioners/connection.html
  */

  provisioner "remote-exec" {
    inline = ["sudo apt-get install -y python3"]
  }
  
  connection {
      user = "${var.connection_user}"
      type = "${var.connection_type}"
      private_key = file("${var.ssh_private_key}")
      timeout = "${var.connection_timeout}"
      host = "${self.ipv4_address}"
  }

  provisioner "local-exec" {
    working_dir = "../ansible/"
    command     = "ansible-playbook -u root -e 'ansible_python_interpreter=/usr/bin/python3' --private-key ${var.ssh_private_key} provision.yml -i ${self.ipv4_address},"
  }

}
