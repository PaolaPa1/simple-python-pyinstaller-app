terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

provider "docker" {}

# Creamos la red Docker bridge para conectar Jenkins y dind
resource "docker_network" "jenkins" {
  name = "red_jenkins"
}

resource "docker_volume" "jenkins_data" {
  name = "jenkins-data"
}

resource "docker_volume" "jenkins_certs" {
  name = "jenkins-docker-certs"
}

# Creamos el contenedor dind con la imagen docker:dind
resource "docker_container" "jenkins_docker" {
  name         = "jenkinsDocker"
  image        = "docker:dind"

  networks_advanced {
    name    = docker_network.jenkins.name
    aliases = ["red_jenkins"]
  }

  ports {
    internal = 2376
    external = 2376
  }

  env = [
    "DOCKER_TLS_CERTDIR=/certs",
  ]

  privileged = true

  volumes {
    volume_name    = docker_volume.jenkins_certs.name
    container_path = "/certs/client"
  }

  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }
}

# Contenedor Jenkins con la imagen personalizada con Dockerfile
resource "docker_container" "jenkins_blueocean" {
  name  = "jenkinsBlueocean"
  image = "myjenkins_bo:latest"
  
  # Se reinicia automáticamente en caso de error
  restart = "on-failure"

  # Variables de entorno
  env = [
    "DOCKER_HOST=tcp://jenkinsDocker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1",
  ]

  privileged = true

  networks_advanced {
    name    = docker_network.jenkins.name
    aliases = ["red_jenkins"]
  }

  # Volúmenes
  volumes {
    volume_name = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name = docker_volume.jenkins_certs.name
    container_path= "/certs/client"
    read_only = true
  }
  
  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }

  depends_on = [
    docker_network.jenkins
  ]
}
