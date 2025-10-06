terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15"
    }
  }
}

# MongoDB Atlas Project
resource "mongodbatlas_project" "project" {
  name   = var.project_name
  org_id = var.org_id

  dynamic "teams" {
    for_each = var.teams
    content {
      team_id    = teams.value.team_id
      role_names = teams.value.role_names
    }
  }
}

# MongoDB Atlas Cluster
resource "mongodbatlas_cluster" "cluster" {
  project_id = mongodbatlas_project.project.id
  name       = var.cluster_name

  # Provider Settings
  provider_name               = var.provider_name
  backing_provider_name       = var.backing_provider_name
  provider_region_name        = var.region
  provider_instance_size_name = var.instance_size

  # Cluster Configuration
  cluster_type = var.cluster_type
  mongo_db_major_version = var.mongodb_version

  # Auto-scaling
  auto_scaling_disk_gb_enabled = var.auto_scaling_disk_gb_enabled

  dynamic "replication_specs" {
    for_each = var.cluster_type == "REPLICASET" ? [1] : []
    content {
      num_shards = 1
      regions_config {
        region_name     = var.region
        electable_nodes = var.electable_nodes
        priority        = 7
        read_only_nodes = var.read_only_nodes
      }
    }
  }

  # Backup
  pit_enabled                   = var.pit_enabled
  cloud_backup                  = var.cloud_backup
  backup_enabled                = var.backup_enabled

  # Advanced Configuration
  advanced_configuration {
    javascript_enabled                   = var.javascript_enabled
    minimum_enabled_tls_protocol        = var.minimum_tls_protocol
    no_table_scan                       = var.no_table_scan
    oplog_size_mb                       = var.oplog_size_mb
    sample_size_bi_connector            = var.sample_size_bi_connector
    sample_refresh_interval_bi_connector = var.sample_refresh_interval_bi_connector
  }

  # Labels
  dynamic "labels" {
    for_each = var.labels
    content {
      key   = labels.value.key
      value = labels.value.value
    }
  }
}

# Database User
resource "mongodbatlas_database_user" "user" {
  count              = var.create_database_user ? 1 : 0
  username           = var.database_username
  password           = var.database_password
  project_id         = mongodbatlas_project.project.id
  auth_database_name = "admin"

  dynamic "roles" {
    for_each = var.database_user_roles
    content {
      role_name     = roles.value.role_name
      database_name = roles.value.database_name
    }
  }

  dynamic "scopes" {
    for_each = var.database_user_scopes
    content {
      name = scopes.value.name
      type = scopes.value.type
    }
  }
}

# IP Access List
resource "mongodbatlas_project_ip_access_list" "ip" {
  for_each   = var.ip_access_list
  project_id = mongodbatlas_project.project.id
  cidr_block = each.value.cidr_block
  comment    = each.value.comment
}

# Network Peering (AWS)
resource "mongodbatlas_network_peering" "aws_peer" {
  count            = var.enable_aws_peering ? 1 : 0
  project_id       = mongodbatlas_project.project.id
  container_id     = mongodbatlas_cluster.cluster.container_id
  accepter_region_name = var.aws_peer_region
  provider_name    = "AWS"
  route_table_cidr_block = var.aws_route_table_cidr_block
  vpc_id           = var.aws_vpc_id
  aws_account_id   = var.aws_account_id
}

# Private Endpoint (AWS)
resource "mongodbatlas_privatelink_endpoint" "endpoint" {
  count          = var.enable_private_endpoint ? 1 : 0
  project_id     = mongodbatlas_project.project.id
  provider_name  = var.provider_name
  region         = var.region
}

# Encryption at Rest
resource "mongodbatlas_encryption_at_rest" "encryption" {
  count      = var.enable_encryption_at_rest ? 1 : 0
  project_id = mongodbatlas_project.project.id

  aws_kms_config {
    enabled                = true
    customer_master_key_id = var.aws_kms_key_id
    region                 = var.aws_kms_region
    role_id                = var.aws_kms_role_id
  }
}

# Auditing
resource "mongodbatlas_auditing" "auditing" {
  count                    = var.enable_auditing ? 1 : 0
  project_id               = mongodbatlas_project.project.id
  audit_filter             = var.audit_filter
  audit_authorization_success = var.audit_authorization_success
  enabled                  = true
}

# Maintenance Window
resource "mongodbatlas_maintenance_window" "maintenance" {
  count              = var.enable_maintenance_window ? 1 : 0
  project_id         = mongodbatlas_project.project.id
  day_of_week        = var.maintenance_day_of_week
  hour_of_day        = var.maintenance_hour_of_day
  auto_defer_once_enabled = var.auto_defer_maintenance
}

# Alerts
resource "mongodbatlas_alert_configuration" "alert" {
  for_each   = var.alerts
  project_id = mongodbatlas_project.project.id
  event_type = each.value.event_type
  enabled    = each.value.enabled

  dynamic "notification" {
    for_each = each.value.notifications
    content {
      type_name     = notification.value.type_name
      interval_min  = notification.value.interval_min
      delay_min     = notification.value.delay_min
      sms_enabled   = notification.value.sms_enabled
      email_enabled = notification.value.email_enabled
    }
  }

  dynamic "matcher" {
    for_each = each.value.matchers
    content {
      field_name = matcher.value.field_name
      operator   = matcher.value.operator
      value      = matcher.value.value
    }
  }

  dynamic "metric_threshold_config" {
    for_each = each.value.metric_threshold != null ? [each.value.metric_threshold] : []
    content {
      metric_name = metric_threshold_config.value.metric_name
      operator    = metric_threshold_config.value.operator
      threshold   = metric_threshold_config.value.threshold
      units       = metric_threshold_config.value.units
      mode        = metric_threshold_config.value.mode
    }
  }
}
