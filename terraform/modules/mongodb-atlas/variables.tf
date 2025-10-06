variable "org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "project_name" {
  description = "MongoDB Atlas Project Name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas Cluster"
  type        = string
}

variable "provider_name" {
  description = "Cloud provider name (AWS, GCP, AZURE, TENANT)"
  type        = string
  default     = "AWS"
}

variable "backing_provider_name" {
  description = "Backing cloud provider for TENANT clusters"
  type        = string
  default     = ""
}

variable "region" {
  description = "Cloud provider region"
  type        = string
}

variable "instance_size" {
  description = "Atlas instance size (e.g., M10, M20, M30)"
  type        = string
  default     = "M10"
}

variable "cluster_type" {
  description = "Cluster type (REPLICASET or SHARDED)"
  type        = string
  default     = "REPLICASET"
}

variable "mongodb_version" {
  description = "MongoDB major version"
  type        = string
  default     = "7.0"
}

variable "auto_scaling_disk_gb_enabled" {
  description = "Enable disk auto-scaling"
  type        = bool
  default     = true
}

variable "electable_nodes" {
  description = "Number of electable nodes"
  type        = number
  default     = 3
}

variable "read_only_nodes" {
  description = "Number of read-only nodes"
  type        = number
  default     = 0
}

variable "pit_enabled" {
  description = "Enable Point-in-Time restore"
  type        = bool
  default     = false
}

variable "cloud_backup" {
  description = "Enable cloud backup"
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Enable legacy backup (deprecated)"
  type        = bool
  default     = false
}

variable "javascript_enabled" {
  description = "Enable server-side JavaScript"
  type        = bool
  default     = true
}

variable "minimum_tls_protocol" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLS1_2"
}

variable "no_table_scan" {
  description = "Disable table scans"
  type        = bool
  default     = false
}

variable "oplog_size_mb" {
  description = "Oplog size in MB"
  type        = number
  default     = null
}

variable "sample_size_bi_connector" {
  description = "Sample size for BI Connector"
  type        = number
  default     = null
}

variable "sample_refresh_interval_bi_connector" {
  description = "Sample refresh interval for BI Connector"
  type        = number
  default     = null
}

variable "labels" {
  description = "List of labels for the cluster"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "teams" {
  description = "Teams associated with the project"
  type = list(object({
    team_id    = string
    role_names = list(string)
  }))
  default = []
}

variable "create_database_user" {
  description = "Create a database user"
  type        = bool
  default     = true
}

variable "database_username" {
  description = "Database user username"
  type        = string
  default     = ""
}

variable "database_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "database_user_roles" {
  description = "Database user roles"
  type = list(object({
    role_name     = string
    database_name = string
  }))
  default = [
    {
      role_name     = "readWriteAnyDatabase"
      database_name = "admin"
    }
  ]
}

variable "database_user_scopes" {
  description = "Database user scopes"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "ip_access_list" {
  description = "IP addresses or CIDR blocks allowed to access the cluster"
  type = map(object({
    cidr_block = string
    comment    = string
  }))
  default = {}
}

variable "enable_aws_peering" {
  description = "Enable AWS VPC peering"
  type        = bool
  default     = false
}

variable "aws_peer_region" {
  description = "AWS region for VPC peering"
  type        = string
  default     = ""
}

variable "aws_route_table_cidr_block" {
  description = "AWS VPC CIDR block for peering"
  type        = string
  default     = ""
}

variable "aws_vpc_id" {
  description = "AWS VPC ID for peering"
  type        = string
  default     = ""
}

variable "aws_account_id" {
  description = "AWS Account ID for peering"
  type        = string
  default     = ""
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "enable_encryption_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = false
}

variable "aws_kms_key_id" {
  description = "AWS KMS Customer Master Key ID"
  type        = string
  default     = ""
}

variable "aws_kms_region" {
  description = "AWS KMS region"
  type        = string
  default     = ""
}

variable "aws_kms_role_id" {
  description = "AWS KMS role ID"
  type        = string
  default     = ""
}

variable "enable_auditing" {
  description = "Enable auditing"
  type        = bool
  default     = false
}

variable "audit_filter" {
  description = "JSON audit filter"
  type        = string
  default     = ""
}

variable "audit_authorization_success" {
  description = "Enable auditing of authorization successes"
  type        = bool
  default     = false
}

variable "enable_maintenance_window" {
  description = "Enable maintenance window"
  type        = bool
  default     = false
}

variable "maintenance_day_of_week" {
  description = "Day of week for maintenance (1-7)"
  type        = number
  default     = 7
}

variable "maintenance_hour_of_day" {
  description = "Hour of day for maintenance (0-23)"
  type        = number
  default     = 2
}

variable "auto_defer_maintenance" {
  description = "Auto-defer maintenance once"
  type        = bool
  default     = false
}

variable "alerts" {
  description = "Alert configurations"
  type = map(object({
    event_type = string
    enabled    = bool
    notifications = list(object({
      type_name     = string
      interval_min  = number
      delay_min     = number
      sms_enabled   = bool
      email_enabled = bool
    }))
    matchers = list(object({
      field_name = string
      operator   = string
      value      = string
    }))
    metric_threshold = object({
      metric_name = string
      operator    = string
      threshold   = number
      units       = string
      mode        = string
    })
  }))
  default = {}
}
