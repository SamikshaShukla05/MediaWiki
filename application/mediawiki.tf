
provider "kubernetes" {
    config_path = "/root/.kube/config"
}

resource "kubernetes_deployment" "mediawiki" {
    metadata {
        name = "mediawiki"
        labels = {
            app   = "mediawiki"
        }
    }
    
    spec {
        replicas = 1
        selector {
            match_labels = {
                app   = "mediawiki"
            } 
        } 
        template { 
            metadata {
                labels = {
                    app   = "mediawiki"
                } 
            } 
            spec {
                container {
                    image = "mediawiki:latest"   
                    name  = "mediawiki"          
                    port { 
                        container_port = 80
                    }
                } 
            } 
        } 
    } 
} 

resource "kubernetes_service" "mediawiki_service" {
  metadata {
    name = "mediawiki-service"
  } 
  spec {
    selector = {
      app = "mediawiki"
    } 
    port {
      port      = 80
    } 
    type = "LoadBalancer"
  } 
}