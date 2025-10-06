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

# Multi-region cluster example
resource "mongodbatlas_project" "multi_region" {
  name   = "multi-region-project"
  org_id = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "multi_region" {
  project_id = mongodbatlas_project.multi_region.id
  name       = "multi-region-cluster"

  cluster_type = "REPLICASET"

  provider_name               = "AWS"
  provider_instance_size_name = "M30"

  mongo_db_major_version = "7.0"

  # Multi-region configuration
  replication_specs {
    num_shards = 1

    # US East Region (Primary)
    regions_config {
      region_name     = "US_EAST_1"
      electable_nodes = 2
      priority        = 7
      read_only_nodes = 0
    }

    # US West Region
    regions_config {
      region_name     = "US_WEST_2"
      electable_nodes = 1
      priority        = 6
      read_only_nodes = 0
    }

    # EU Region (Read-only analytics)
    regions_config {
      region_name     = "EU_WEST_1"
      electable_nodes = 0
      priority        = 0
      read_only_nodes = 2
    }
  }

  cloud_backup                 = true
  pit_enabled                  = true
  auto_scaling_disk_gb_enabled = true

  advanced_configuration {
    javascript_enabled           = false
    minimum_enabled_tls_protocol = "TLS1_2"
  }

  labels {
    key   = "environment"
    value = "production"
  }

  labels {
    key   = "multi-region"
    value = "true"
  }
}

# Database users
resource "mongodbatlas_database_user" "app_user" {
  username           = "app-user"
  password           = var.database_password
  project_id         = mongodbatlas_project.multi_region.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "production"
  }

  scopes {
    name = mongodbatlas_cluster.multi_region.name
    type = "CLUSTER"
  }
}

resource "mongodbatlas_database_user" "analytics_user" {
  username           = "analytics-user"
  password           = var.analytics_password
  project_id         = mongodbatlas_project.multi_region.id
  auth_database_name = "admin"

  roles {
    role_name     = "read"
    database_name = "production"
  }

  scopes {
    name = mongodbatlas_cluster.multi_region.name
    type = "CLUSTER"
  }
}

# IP Access List for different regions
resource "mongodbatlas_project_ip_access_list" "us_east" {
  project_id = mongodbatlas_project.multi_region.id
  cidr_block = "10.0.0.0/16"
  comment    = "US East VPC"
}

resource "mongodbatlas_project_ip_access_list" "us_west" {
  project_id = mongodbatlas_project.multi_region.id
  cidr_block = "10.1.0.0/16"
  comment    = "US West VPC"
}

resource "mongodbatlas_project_ip_access_list" "eu_west" {
  project_id = mongodbatlas_project.multi_region.id
  cidr_block = "10.2.0.0/16"
  comment    = "EU West VPC"
}

output "connection_string" {
  description = "MongoDB multi-region connection string"
  value       = mongodbatlas_cluster.multi_region.connection_strings[0].standard_srv
  sensitive   = true
}

output "cluster_state" {
  description = "Cluster state"
  value       = mongodbatlas_cluster.multi_region.state_name
}

output "srv_address" {
  description = "SRV address for the cluster"
  value       = mongodbatlas_cluster.multi_region.srv_address
}
