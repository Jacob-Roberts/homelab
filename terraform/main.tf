terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.38.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.30.0"
    }
  }
}

provider "oci" {
  region              = var.region
  auth                = "SecurityToken"
  config_file_profile = "DEFAULT"
}

resource "oci_core_vcn" "internal" {
  dns_label      = "vcn08101552"
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "Default VCN"
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "default/jroberts.glql8@simplelogin.com"
    "Oracle-Tags.CreatedOn" = "2022-08-10T21:52:14.273Z"
  }
}

resource "oci_core_subnet" "default_subnet" {
  vcn_id                     = oci_core_vcn.internal.id
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = var.compartment_id
  display_name               = "subnet-20220810-1550"
  prohibit_public_ip_on_vnic = false
  dns_label                  = "subnet08101552"
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "default/jroberts.glql8@simplelogin.com"
    "Oracle-Tags.CreatedOn" = "2022-08-10T21:52:18.876Z"
  }
  security_list_ids = [
    oci_core_security_list.default_security_list.id,
  ]
}

resource "oci_core_security_list" "default_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.internal.id

  egress_security_rules {
    description      = "Allow all traffic to the internet"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    description = "Allow ICMP Traffic"
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = -1
      type = 3
    }
  }

  ingress_security_rules {
    description = "Allow ICMP Traffic"
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }

  ingress_security_rules {
    description = "Allow SSH from anywhere"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Allow HTTP Traffic"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 80
      min = 80
    }
  }
  ingress_security_rules {
    description = "Allow HTTPS Traffic"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }
  ingress_security_rules {
    description = "Tailscale IPV4 Direct Connections"
    protocol    = "17"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = true

    udp_options {
      max = 41641
      min = 41641
    }
  }
}

