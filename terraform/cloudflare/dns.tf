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

////////////////////////
//      IAD1 VPN      //
////////////////////////

resource "cloudflare_dns_record" "iad1-vpn-node-1" {
  name    = "iad1-vpn-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "100.109.65.68"
}

resource "cloudflare_dns_record" "iad1-vpn-node-2" {
  name    = "iad1-vpn-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "100.107.169.91"
}

resource "cloudflare_dns_record" "iad1-vpn-node-3" {
  name    = "iad1-vpn-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "100.70.105.44"
}

resource "cloudflare_dns_record" "iad1_vpn_catch_all" {
  name    = "*.iad1vpn.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content   = "iad1-vpn-node-1.jakerob.pro"
}

////////////////////////
//    Homelab LHR1    //
////////////////////////

resource "cloudflare_dns_record" "lhr1-proxmox-node-1" {
  name    = "lhr1-proxmox-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.10"
}

resource "cloudflare_dns_record" "lhr1-node-2" {
  name    = "lhr1-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.3"
}

resource "cloudflare_dns_record" "lhr1_catch_all" {
  name    = "*.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content   = "lhr1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "proxmox-lhr1-cname" {
  name    = "proxmox.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content   = "lhr1-proxmox-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "lhr1-dev-1" {
  name    = "lhr1-dev-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.211"
}

resource "cloudflare_dns_record" "lhr1-node-1" {
  name    = "lhr1-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.16"
}

resource "cloudflare_dns_record" "lhr1-node-3" {
  name    = "lhr1-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.13"
}

resource "cloudflare_dns_record" "lhr1-nut-1" {
  name    = "lhr1-nut-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content   = "192.168.42.12"
}

////////////////////////
//     Email          //
////////////////////////

resource "cloudflare_dns_record" "DMARC" {
  name    = "_dmarc.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content   = "v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;"
}

resource "cloudflare_dns_record" "resend" {
  name    = "resend._domainkey.accounts.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content   = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB"
}

resource "cloudflare_dns_record" "send" {
  name    = "send.accounts.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content   = "v=spf1 include:amazonses.com ~all"
}
