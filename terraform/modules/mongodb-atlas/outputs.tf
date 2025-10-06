output "project_id" {
  description = "MongoDB Atlas Project ID"
  value       = mongodbatlas_project.project.id
}

output "cluster_id" {
  description = "MongoDB Atlas Cluster ID"
  value       = mongodbatlas_cluster.cluster.cluster_id
}

output "cluster_name" {
  description = "MongoDB Atlas Cluster Name"
  value       = mongodbatlas_cluster.cluster.name
}

output "connection_strings" {
  description = "MongoDB Atlas connection strings"
  value       = mongodbatlas_cluster.cluster.connection_strings
  sensitive   = true
}

output "standard_connection_string" {
  description = "Standard MongoDB connection string"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].standard
  sensitive   = true
}

output "standard_srv_connection_string" {
  description = "Standard SRV MongoDB connection string"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
  sensitive   = true
}

output "private_connection_string" {
  description = "Private MongoDB connection string"
  value       = length(mongodbatlas_cluster.cluster.connection_strings[0].private) > 0 ? mongodbatlas_cluster.cluster.connection_strings[0].private : null
  sensitive   = true
}

output "private_srv_connection_string" {
  description = "Private SRV MongoDB connection string"
  value       = length(mongodbatlas_cluster.cluster.connection_strings[0].private_srv) > 0 ? mongodbatlas_cluster.cluster.connection_strings[0].private_srv : null
  sensitive   = true
}

output "mongo_uri" {
  description = "Base MongoDB URI"
  value       = mongodbatlas_cluster.cluster.mongo_uri
  sensitive   = true
}

output "mongo_uri_updated" {
  description = "Updated MongoDB URI"
  value       = mongodbatlas_cluster.cluster.mongo_uri_updated
  sensitive   = true
}

output "mongo_uri_with_options" {
  description = "MongoDB URI with options"
  value       = mongodbatlas_cluster.cluster.mongo_uri_with_options
  sensitive   = true
}

output "state_name" {
  description = "Current state of the cluster"
  value       = mongodbatlas_cluster.cluster.state_name
}

output "srv_address" {
  description = "SRV address for the cluster"
  value       = mongodbatlas_cluster.cluster.srv_address
}

output "container_id" {
  description = "Network container ID"
  value       = mongodbatlas_cluster.cluster.container_id
}

output "database_user_username" {
  description = "Database user username"
  value       = var.create_database_user ? mongodbatlas_database_user.user[0].username : null
}

output "private_endpoint_id" {
  description = "Private endpoint ID"
  value       = var.enable_private_endpoint ? mongodbatlas_privatelink_endpoint.endpoint[0].private_link_id : null
}

output "private_endpoint_service_name" {
  description = "Private endpoint service name"
  value       = var.enable_private_endpoint ? mongodbatlas_privatelink_endpoint.endpoint[0].endpoint_service_name : null
}

output "peering_connection_id" {
  description = "VPC peering connection ID"
  value       = var.enable_aws_peering ? mongodbatlas_network_peering.aws_peer[0].connection_id : null
}
