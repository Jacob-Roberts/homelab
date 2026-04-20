# Oracle Credentials
# ---
# Credential Variables needed for oracle

ephemeral "infisical_secret" "tenancy_ocid" {
  name         = "TENANCY_OCID"
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/oci/iad1"
}

ephemeral "infisical_secret" "user_ocid" {
  name         = "USER_OCID"
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/oci/iad1"
}

ephemeral "infisical_secret" "rsa_private_key" {
  name         = "RSA_PRIVATE_KEY"
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/oci/iad1"
}

ephemeral "infisical_secret" "fingerprint" {
  name         = "FINGERPRINT"
  workspace_id = var.infisical_project_id
  env_slug     = var.infisical_env_slug
  folder_path  = "/global/oci/iad1"
}

variable "region" {
  description = "region where you have OCI tenancy"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "Compartment ocid where to create all resources"
  type        = string
}

# Infisical Credentials
# ---
# Credential Variables needed for Infisical

variable "infisical_client_id" {
  description = "Infisical Machine Identity Client ID"
  type        = string
  sensitive   = true
}

variable "infisical_client_secret" {
  description = "Infisical Machine Identity Client Secret"
  type        = string
  sensitive   = true
}

variable "infisical_project_id" {
  description = "Infisical Project ID (formerly workspace_id)"
  type        = string
}

variable "infisical_env_slug" {
  type        = string
  description = "Infisical environment slug (e.g., dev, staging, prod)"
  default     = "prod"
}
