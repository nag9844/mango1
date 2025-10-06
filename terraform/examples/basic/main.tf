terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

module "mongodb_atlas" {
  source = "../../modules/mongodb-atlas"

  # Project Configuration
  org_id       = var.mongodb_atlas_org_id
  project_name = "my-project"

  # Cluster Configuration
  cluster_name  = "my-cluster"
  provider_name = "AWS"
  region        = "US_EAST_1"
  instance_size = "M10"

  # MongoDB Version
  mongodb_version = "7.0"

  # Auto-scaling
  auto_scaling_disk_gb_enabled = true

  # Backup
  cloud_backup = true
  pit_enabled  = false

  # Database User
  create_database_user = true
  database_username    = "app-user"
  database_password    = var.database_password

  database_user_roles = [
    {
      role_name     = "readWrite"
      database_name = "myapp"
    }
  ]

  # IP Access List
  ip_access_list = {
    office = {
      cidr_block = "203.0.113.0/24"
      comment    = "Office IP range"
    }
    vpn = {
      cidr_block = "198.51.100.0/24"
      comment    = "VPN IP range"
    }
  }

  # Labels
  labels = [
    {
      key   = "environment"
      value = "production"
    },
    {
      key   = "team"
      value = "backend"
    }
  ]
}

output "connection_string" {
  description = "MongoDB connection string"
  value       = module.mongodb_atlas.standard_srv_connection_string
  sensitive   = true
}

output "cluster_id" {
  description = "Cluster ID"
  value       = module.mongodb_atlas.cluster_id
}
