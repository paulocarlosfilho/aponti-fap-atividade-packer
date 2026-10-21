packer {
  required_plugins {
    docker = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# 1. Definição da Imagem Base (Builder Docker com Ubuntu Jammy)
source "docker" "ubuntu_base" {
  image  = "ubuntu:jammy"
  commit = true
  changes = [
    "EXPOSE 80",
    "CMD [\"/usr/sbin/apachectl\", \"-D\", \"FOREGROUND\"]"
  ]
}

# 2. Bloco de Build e Provisionamento
build {
  name    = "construir-apache"
  sources = ["source.docker.ubuntu_base"]

  # PASSO A: Atualiza os pacotes e instala o apache2 PRIMEIRO
  # Isso garante que a pasta /var/www/html/ seja criada antes de copiar o ficheiro
  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y apache2",
      "apt-get clean"
    ]
  }

  # PASSO B: Copia o ficheiro index.html da máquina local para a imagem
  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"
  }

  # PASSO C: Nomeia e aplica a tag na imagem final criada
  post-processor "docker-tag" {
    repository = "meu-apache-packer"
    tags       = ["latest"]
  }
}