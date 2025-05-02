////////////////////////
//  Examples          //
////////////////////////

// Only required options
# resource "cloudflare_dns_record" "my_main_record" {
#   name    = "jakerob.pro"
#   proxied = false
#   ttl     = 1 // 1 Means "automatic"
#   type    = "A"
#   zone_id = "023e105f4ecef8ad9ca31a8372d0c353"
#   content   = "76.76.21.21"
# }

// All possible options
# resource "cloudflare_dns_record" "example_dns_record" {
#   zone_id = "023e105f4ecef8ad9ca31a8372d0c353"
#   comment = "Domain verification record"
#   content = "198.51.100.4"
#   name = "example.com"
#   proxied = true
#   settings = {
#     ipv4_only = true
#     ipv6_only = true
#   }
#   tags = ["owner:dns-team"]
#   ttl = 3600
#   type = "A"
# }


////////////////////////
// Cloudflare ZoneIDs //
////////////////////////

# jakerob.pro         6e98165e20ed0ba1b018f543c6ab4285
# autovation.com      dc32b6130553f5adc9972f7f27b438cf
# boxworks.com        47b92560b198de930fb9ade0f5a72888
# dcforesight.com     23b2166e9eb7c07cfcded23609f652ef
# quickloadpay.com    782856dc4be2f0d48c747c950103beca
# wanderinglaine.com  3aa16e0a1cc88acde128e2ba0d2766b0

////////////////////////
//  Vercel Records    //
////////////////////////

resource "cloudflare_dns_record" "jakerob_apex_record" {
  name    = "jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "76.76.21.21"
}

resource "cloudflare_dns_record" "jakerob_www_record" {
  name    = "www.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "76.76.21.21"
}

////////////////////////
//        IAD1        //
////////////////////////

resource "cloudflare_dns_record" "iad1-node-1" {
  name    = "iad1-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "150.136.144.201"
}

resource "cloudflare_dns_record" "iad1-node-2" {
  name    = "iad1-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "129.158.205.205"
}

resource "cloudflare_dns_record" "iad1-node-3" {
  name    = "iad1-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "150.136.240.69"
}

resource "cloudflare_dns_record" "iad1_catch_all" {
  name    = "*.iad1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content   = "iad1-node-1.jakerob.pro"
}

# ////////////////////////
# // Cloud VPN Records  //
# ////////////////////////

# resource "cloudflare_dns_record" "terraform_managed_resource_d3aed3a001d9a30edf4a2bf22b09bb7a" {
#   name    = "iad1-vpn-node-1"
#   proxied = false
#   ttl     = 1
#   type    = "A"
#   content   = "100.108.112.55"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_886b761c56d612056bb4c23581552fc2" {
#   name    = "*.iad1vpn"
#   proxied = false
#   ttl     = 1
#   type    = "CNAME"
#   content   = "iad1-vpn-node-1.jakerob.pro"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# ////////////////////////
# //     Homelab        //
# ////////////////////////

# resource "cloudflare_dns_record" "terraform_managed_resource_2ccf64b369328fed61e66f150105e242" {
#   name    = "lhr1-proxmox-node-1"
#   proxied = false
#   ttl     = 1
#   type    = "A"
#   content   = "192.168.42.10"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_62223054cc6f14b22f45a3b797e2e2c5" {
#   name    = "lhr1-node-2"
#   proxied = false
#   ttl     = 1
#   type    = "A"
#   content   = "192.168.42.15"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_cf974556d63574d6fb945ecf04d9d0e6" {
#   name    = "*.lhr1"
#   proxied = false
#   ttl     = 1
#   type    = "CNAME"
#   content   = "lhr1-node-2.jakerob.pro"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_ae656a93eaabac08ce6ce20709ce6f90" {
#   name    = "proxmox.lhr1"
#   proxied = false
#   ttl     = 1
#   type    = "CNAME"
#   content   = "lhr1-proxmox-node-1.jakerob.pro"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# ////////////////////////
# //     Email          //
# ////////////////////////

# resource "cloudflare_dns_record" "terraform_managed_resource_0cd962e47bda3ed9c7437073ec661c6e" {
#   name    = "_dmarc"
#   proxied = false
#   ttl     = 1
#   type    = "TXT"
#   content   = "v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_30cd57fce8ef38e533081fe12de27a3c" {
#   name    = "resend._domainkey.accounts"
#   proxied = false
#   ttl     = 1
#   type    = "TXT"
#   content   = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }

# resource "cloudflare_dns_record" "terraform_managed_resource_820fd66aa141f5d30e4c12ff9a423fe2" {
#   name    = "send.accounts"
#   proxied = false
#   ttl     = 1
#   type    = "TXT"
#   content   = "v=spf1 include:amazonses.com ~all"
#   zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
# }
