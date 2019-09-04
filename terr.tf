provider "google" {
  credentials = "${file("project.json")}"
  project     = "project-248515"
  region      = "europe-north1"
  zone        = "europe-north1-a"
}

resource "google_container_cluster" "hey" {
  name = "kluster"

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  node_pool {
    initial_node_count = 3

    management {
      auto_repair = true
    }

    autoscaling {
      min_node_count = 1
      max_node_count = 9
    }

    node_config {
      disk_size_gb = 20
    }

  }

}

#gcloud container clusters get-credentials kluster --zone europe-north1-a --project project-248515

resource "kubernetes_pod" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      App = "jenkins"
    }
  }
  spec {
    container {
      image = "gcr.io/project-248515/jank:my-v"
      name  = "jenkins"

      port {
        container_port = 8080
      }
    }
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name = "jenkins"
  }
  spec {
    selector = {
      App = "${kubernetes_pod.jenkins.metadata.0.labels.App}"
    }
#    session_affinity = "ClientIP"
    port {
      port = 80
      target_port = 8080
   }
  type = "LoadBalancer"
  }
 }
