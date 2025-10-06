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

module "mongodb_atlas_production" {
  source = "../../modules/mongodb-atlas"

  # Project Configuration
  org_id       = var.mongodb_atlas_org_id
  project_name = "production-project"

  # Cluster Configuration
  cluster_name  = "production-cluster"
  provider_name = "AWS"
  region        = "US_EAST_1"
  instance_size = "M30"
  cluster_type  = "REPLICASET"

  # High Availability
  electable_nodes = 3
  read_only_nodes = 2

  # MongoDB Version
  mongodb_version = "7.0"

  # Auto-scaling
  auto_scaling_disk_gb_enabled = true

  # Backup
  cloud_backup = true
  pit_enabled  = true

  # Advanced Configuration
  javascript_enabled       = false
  minimum_tls_protocol     = "TLS1_2"
  no_table_scan           = true

  # Database Users
  create_database_user = true
  database_username    = "app-user"
  database_password    = var.database_password

  database_user_roles = [
    {
      role_name     = "readWrite"
      database_name = "production"
    },
    {
      role_name     = "read"
      database_name = "analytics"
    }
  ]

  # IP Access List
  ip_access_list = {
    vpc_cidr = {
      cidr_block = "10.0.0.0/16"
      comment    = "VPC CIDR block"
    }
  }

  # AWS VPC Peering
  enable_aws_peering         = true
  aws_peer_region           = "us-east-1"
  aws_route_table_cidr_block = "10.0.0.0/16"
  aws_vpc_id                = var.aws_vpc_id
  aws_account_id            = var.aws_account_id

  # Private Endpoint
  enable_private_endpoint = true

  # Encryption at Rest
  enable_encryption_at_rest = true
  aws_kms_key_id           = var.aws_kms_key_id
  aws_kms_region           = "us-east-1"
  aws_kms_role_id          = var.aws_kms_role_id

  # Auditing
  enable_auditing              = true
  audit_authorization_success  = true
  audit_filter                = jsonencode({
    atype = "authenticate"
    "param.db" = "admin"
  })

  # Maintenance Window
  enable_maintenance_window = true
  maintenance_day_of_week   = 7  # Sunday
  maintenance_hour_of_day   = 2  # 2 AM
  auto_defer_maintenance    = true

  # Alerts
  alerts = {
    high_cpu = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      enabled    = true
      notifications = [
        {
          type_name     = "EMAIL"
          interval_min  = 5
          delay_min     = 0
          sms_enabled   = false
          email_enabled = true
        }
      ]
      matchers = [
        {
          field_name = "HOSTNAME_AND_PORT"
          operator   = "EQUALS"
          value      = "PRIMARY"
        }
      ]
      metric_threshold = {
        metric_name = "SYSTEM_CPU_USER"
        operator    = "GREATER_THAN"
        threshold   = 80
        units       = "RAW"
        mode        = "AVERAGE"
      }
    }
    low_connections = {
      event_type = "OUTSIDE_METRIC_THRESHOLD"
      enabled    = true
      notifications = [
        {
          type_name     = "EMAIL"
          interval_min  = 5
          delay_min     = 0
          sms_enabled   = false
          email_enabled = true
        }
      ]
      matchers = []
      metric_threshold = {
        metric_name = "CONNECTIONS"
        operator    = "GREATER_THAN"
        threshold   = 1000
        units       = "RAW"
        mode        = "AVERAGE"
      }
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
      value = "platform"
    },
    {
      key   = "managed-by"
      value = "terraform"
    }
  ]
}

output "connection_string" {
  description = "MongoDB connection string"
  value       = module.mongodb_atlas_production.standard_srv_connection_string
  sensitive   = true
}

output "private_connection_string" {
  description = "MongoDB private connection string"
  value       = module.mongodb_atlas_production.private_srv_connection_string
  sensitive   = true
}

output "cluster_state" {
  description = "Cluster state"
  value       = module.mongodb_atlas_production.state_name
}
