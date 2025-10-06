# MongoDB Atlas Terraform Module

Comprehensive Terraform module for provisioning and managing MongoDB Atlas clusters with enterprise features.

## Features

- MongoDB Atlas Project and Cluster provisioning
- Database user management with role-based access control
- IP access list configuration
- AWS VPC peering support
- Private endpoint (PrivateLink) configuration
- Encryption at rest with AWS KMS
- Database auditing
- Maintenance window scheduling
- Alert configuration with multiple notification channels
- Multi-region cluster support
- Backup and Point-in-Time restore configuration

## Prerequisites

1. MongoDB Atlas account
2. MongoDB Atlas API keys (public and private)
3. Organization ID from MongoDB Atlas

### Getting MongoDB Atlas API Keys

1. Log in to [MongoDB Atlas](https://cloud.mongodb.com/)
2. Navigate to **Organization Settings** → **Access Manager** → **API Keys**
3. Click **Create API Key**
4. Save your public and private keys securely
5. Note your Organization ID from the organization settings

## Module Structure

```
terraform/
├── modules/
│   └── mongodb-atlas/
│       ├── main.tf          # Main resources
│       ├── variables.tf     # Input variables
│       └── outputs.tf       # Output values
└── examples/
    ├── basic/              # Basic cluster setup
    ├── advanced/           # Advanced features
    └── multi-region/       # Multi-region deployment
```

## Usage Examples

### Basic Example

```hcl
module "mongodb_atlas" {
  source = "./modules/mongodb-atlas"

  org_id       = "your-org-id"
  project_name = "my-project"
  cluster_name = "my-cluster"

  provider_name = "AWS"
  region        = "US_EAST_1"
  instance_size = "M10"

  database_username = "app-user"
  database_password = "secure-password"

  ip_access_list = {
    office = {
      cidr_block = "203.0.113.0/24"
      comment    = "Office IP"
    }
  }
}
```

### Advanced Example with All Features

```hcl
module "mongodb_atlas" {
  source = "./modules/mongodb-atlas"

  # Project
  org_id       = "your-org-id"
  project_name = "production"

  # Cluster
  cluster_name  = "prod-cluster"
  provider_name = "AWS"
  region        = "US_EAST_1"
  instance_size = "M30"

  # High Availability
  electable_nodes = 3
  read_only_nodes = 2

  # Backup
  cloud_backup = true
  pit_enabled  = true

  # Security
  enable_encryption_at_rest = true
  aws_kms_key_id           = "your-kms-key-id"
  aws_kms_region           = "us-east-1"
  aws_kms_role_id          = "your-kms-role-id"

  # Networking
  enable_aws_peering         = true
  aws_vpc_id                = "vpc-xxxxx"
  aws_account_id            = "123456789012"
  aws_route_table_cidr_block = "10.0.0.0/16"

  # Auditing
  enable_auditing = true

  # Maintenance
  enable_maintenance_window = true
  maintenance_day_of_week   = 7
  maintenance_hour_of_day   = 2
}
```

## Quick Start

1. Navigate to the desired example directory:

```bash
cd terraform/examples/basic
```

2. Create a `terraform.tfvars` file:

```hcl
mongodb_atlas_public_key  = "your-public-key"
mongodb_atlas_private_key = "your-private-key"
mongodb_atlas_org_id      = "your-org-id"
database_password         = "secure-password"
```

3. Initialize Terraform:

```bash
terraform init
```

4. Review the plan:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Input Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `org_id` | MongoDB Atlas Organization ID | `string` |
| `project_name` | Project name | `string` |
| `cluster_name` | Cluster name | `string` |
| `region` | Cloud provider region | `string` |

### Optional Variables

| Name | Description | Default |
|------|-------------|---------|
| `provider_name` | Cloud provider (AWS, GCP, AZURE) | `"AWS"` |
| `instance_size` | Instance size (M10, M20, M30, etc.) | `"M10"` |
| `mongodb_version` | MongoDB version | `"7.0"` |
| `cluster_type` | REPLICASET or SHARDED | `"REPLICASET"` |
| `electable_nodes` | Number of electable nodes | `3` |
| `cloud_backup` | Enable cloud backup | `true` |
| `pit_enabled` | Enable Point-in-Time restore | `false` |

See `modules/mongodb-atlas/variables.tf` for complete list.

## Outputs

| Name | Description |
|------|-------------|
| `connection_strings` | All connection string variants |
| `standard_srv_connection_string` | Standard SRV connection string |
| `cluster_id` | Cluster ID |
| `project_id` | Project ID |
| `state_name` | Current cluster state |

## Instance Sizes

| Size | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| M0 | Shared | 512MB | 512MB (Free tier) |
| M2 | Shared | 2GB | 2GB |
| M5 | Shared | 5GB | 5GB |
| M10 | 2 | 2GB | 10GB |
| M20 | 2 | 4GB | 20GB |
| M30 | 2 | 8GB | 40GB |
| M40 | 4 | 16GB | 80GB |
| M50 | 8 | 32GB | 160GB |

## AWS Regions

Common regions:
- `US_EAST_1` - Virginia
- `US_WEST_2` - Oregon
- `EU_WEST_1` - Ireland
- `AP_SOUTHEAST_1` - Singapore
- `AP_NORTHEAST_1` - Tokyo

## Security Best Practices

1. **Never commit secrets**: Use Terraform variables, environment variables, or secret management tools
2. **Enable encryption at rest**: Use KMS for production clusters
3. **Restrict IP access**: Limit to known IP ranges or use VPC peering
4. **Use private endpoints**: Enable PrivateLink for production
5. **Enable auditing**: Track database access and operations
6. **Rotate credentials**: Regularly rotate API keys and database passwords
7. **Use minimal permissions**: Grant only necessary database roles

## Multi-Region Setup

For global applications, deploy across multiple regions:

```hcl
replication_specs {
  regions_config {
    region_name     = "US_EAST_1"
    electable_nodes = 2
    priority        = 7
  }
  regions_config {
    region_name     = "EU_WEST_1"
    electable_nodes = 1
    priority        = 6
  }
}
```

## Backup and Recovery

- **Cloud Backup**: Automated snapshots with configurable retention
- **Point-in-Time Restore**: Restore to any point in time (requires pit_enabled)
- **Snapshot Schedule**: Configure backup frequency and retention

## Cost Optimization

1. Use appropriate instance sizes (start with M10)
2. Enable auto-scaling for storage
3. Use serverless tier for development (M0)
4. Monitor usage with Atlas metrics
5. Set up billing alerts

## Monitoring and Alerts

Configure alerts for:
- High CPU usage
- Memory pressure
- Connection limits
- Disk space
- Replication lag

Example alert configuration provided in the advanced example.

## Troubleshooting

### Common Issues

1. **Authentication failed**
   - Verify API keys are correct
   - Check API key permissions in Atlas

2. **IP not whitelisted**
   - Add your IP to the access list
   - Check CIDR block format

3. **VPC peering failed**
   - Verify AWS account ID
   - Check VPC CIDR doesn't overlap
   - Confirm IAM permissions

4. **Cluster creation timeout**
   - Atlas cluster creation takes 10-15 minutes
   - Increase Terraform timeout if needed

## Resources

- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [Terraform MongoDB Atlas Provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)
- [MongoDB Connection Strings](https://docs.mongodb.com/manual/reference/connection-string/)

## License

This module is provided as-is for use with MongoDB Atlas.
