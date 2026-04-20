# Oracle Credentials
# ---
# Credential Variables needed for oracle

variable "tenancy_ocid" {
  description = "OCID of the tenancy"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCID of the user calling the API."
  type        = string
  sensitive   = true
}

variable "rsa_private_key" {
  description = "The private key to sign requests with. This should be the actual contents of the file, not a path to the file."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the key pair being used."
  type        = string
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
