############################################
# VCN
############################################

resource "oci_core_vcn" "internal" {
  dns_label      = "vcn08101552"
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "Default VCN"
}

############################################
# Public Subnet
############################################

resource "oci_core_subnet" "default_subnet" {
  vcn_id                     = oci_core_vcn.internal.id
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "subnet-20220810-1550"
  prohibit_public_ip_on_vnic = false
  dns_label                  = "subnet08101552"
  security_list_ids = [
    oci_core_security_list.default_security_list.id,
  ]
}

resource "oci_core_security_list" "default_security_list" {
  compartment_id = var.compartment_ocid
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

  ingress_security_rules {
    description = "Minecraft TCP"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 25565
      min = 25565
    }
  }
  ingress_security_rules {
    description = "Minecraft UDP"
    protocol    = "17"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 25565
      min = 25565
    }
  }
}

#############################################
# Compute Instance
#############################################

resource "oci_core_instance" "iad1-node-1" {
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.A1.Flex"
  availability_domain = "dSgB:US-ASHBURN-AD-2"
  display_name        = "iad1-node-1"

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaa4kk3vwmrprl7elsawu4yincnkteg5yasljeosdly3x25lljfapka"
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = 24
      ocpus         = 4
    }
  }

  create_vnic_details {
    display_name     = "iad1-node-1"
    hostname_label   = "iad1-node-1"
    subnet_id        = oci_core_subnet.default_subnet.id
    assign_public_ip = true
  }
}

resource "oci_core_instance" "iad1-node-2" {
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E2.1.Micro"
  availability_domain = "dSgB:US-ASHBURN-AD-3"
  display_name        = "iad1-node-2"

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaa4dpvjps6vmbqrifoiifaltsq2low27jp2oxohaoswzir3z42ieta"
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = 1
      ocpus         = 1
    }
  }

  create_vnic_details {
    display_name     = "iad1-node-2"
    hostname_label   = "iad1-node-2"
    subnet_id        = oci_core_subnet.default_subnet.id
    assign_public_ip = true
  }
}

resource "oci_core_instance" "iad1-node-3" {
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E2.1.Micro"
  availability_domain = "dSgB:US-ASHBURN-AD-3"
  display_name        = "iad1-node-3"

  source_details {
    source_id   = "ocid1.image.oc1.iad.aaaaaaaajc722fab3jyxiivvrgjzn267ctpgvref5qkhszrnsziigsqa24jq"
    source_type = "image"
  }

  dynamic "shape_config" {
    for_each = [true]
    content {
      #Optional
      memory_in_gbs = 1
      ocpus         = 1
    }
  }

  create_vnic_details {
    display_name     = "iad1-node-3"
    hostname_label   = "iad1-node-3"
    subnet_id        = oci_core_subnet.default_subnet.id
    assign_public_ip = true
  }
}
