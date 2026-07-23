resource "cloudflare_zone" "jakerob_pro" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "jakerob.pro"
  type = "full"
}

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
//  Vercel Records    //
////////////////////////

resource "cloudflare_dns_record" "jakerob_apex_record" {
  name    = "jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
}

resource "cloudflare_dns_record" "jakerob_www_record" {
  name    = "www.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
}

resource "cloudflare_dns_record" "social_signal_vercel" {
  name    = "socialsignal.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "ccfcc2545bc5cf9f.vercel-dns-017.com"
}

resource "cloudflare_dns_record" "social_signal_api" {
  name    = "api.socialsignal.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

////////////////////////
//    Public Apps     //
////////////////////////

resource "cloudflare_dns_record" "jellyfin" {
  name    = "jellyfin.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "karakeep" {
  name    = "karakeep.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "joplin" {
  name    = "joplin.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "calibre" {
  name    = "calibre.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "matrix" {
  name    = "matrix.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "element" {
  name    = "element.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "n8n" {
  name    = "n8n.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

////////////////////////
//        IAD1        //
////////////////////////

resource "cloudflare_dns_record" "iad1-node-1" {
  name    = "iad1-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "150.136.144.201"
}

resource "cloudflare_dns_record" "iad1-node-2" {
  name    = "iad1-node-2.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "129.158.205.205"
}

resource "cloudflare_dns_record" "iad1-node-3" {
  name    = "iad1-node-3.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "150.136.240.69"
}

resource "cloudflare_dns_record" "iad1_catch_all" {
  name    = "*.iad1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

////////////////////////
//      IAD1 VPN      //
////////////////////////

resource "cloudflare_dns_record" "iad1-node-1-vpn" {
  name    = "iad1-node-1.vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.109.65.68"
}

resource "cloudflare_dns_record" "iad1-node-2-vpn" {
  name    = "iad1-node-2.vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.107.169.91"
}

resource "cloudflare_dns_record" "iad1-node-3-vpn" {
  name    = "iad1-node-3.vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.70.105.44"
}

resource "cloudflare_dns_record" "iad1_vpn_catch_all" {
  name    = "*.iad1vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.vpn.jakerob.pro"
}

////////////////////////
//    Homelab PBJ    //
////////////////////////

/* Hostnames */

resource "cloudflare_dns_record" "pbj-router" {
  name    = "pbj-router.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.1"
}

resource "cloudflare_dns_record" "pbj-hv-1" {
  name    = "pbj-hv-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.13"
}

resource "cloudflare_dns_record" "pbj-hv-1-v6" {
  name    = "pbj-hv-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:c05d:7462:fab:171f"
}

resource "cloudflare_dns_record" "pbj-hv-2" {
  name    = "pbj-hv-2.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.11"
}

resource "cloudflare_dns_record" "pbj-hv-2-v6" {
  name    = "pbj-hv-2.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:7fa7:9eef:10bb:1f35"
}

resource "cloudflare_dns_record" "pbj-hv-3" {
  name    = "pbj-hv-3.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.58"
}

resource "cloudflare_dns_record" "pbj-hv-3-v6" {
  name    = "pbj-hv-3.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:2c67:da71:4fb2:ce1a"
}

resource "cloudflare_dns_record" "pbj-node-1" {
  name    = "pbj-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.16"
}

resource "cloudflare_dns_record" "pbj-node-1-v6" {
  name    = "pbj-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "2601:640:8000:a8f0:be24:11ff:feea:1964"
}

resource "cloudflare_dns_record" "pbj-node-1-vpn" {
  name    = "pbj-node-1.vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.81.118.52"
}

resource "cloudflare_dns_record" "pbj-pi-1" {
  name    = "pbj-pi-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.2"
}

resource "cloudflare_dns_record" "pbj-pi-1-v6" {
  name    = "pbj-pi-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:9e36:2401:48e8:b782"
}

resource "cloudflare_dns_record" "wildcard-pbj-pi-1" {
  name    = "*.pbj-pi-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-pi-1.jakerob.pro"
}

resource "cloudflare_dns_record" "pbj-storage-1" {
  name    = "pbj-storage-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.14"
}

resource "cloudflare_dns_record" "pbj-storage-1-v6" {
  name    = "pbj-storage-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:2e2:69ff:fe7d:3c36"
}

resource "cloudflare_dns_record" "pbj-pbs-1" {
  name    = "pbj-pbs-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.19"
}

resource "cloudflare_dns_record" "pbj-pbs-1-v6" {
  name    = "pbj-pbs-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:2ac6:1eb1:6291:a4fd"
}

resource "cloudflare_dns_record" "pbs-pbj" {
  name    = "pbs.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-pbs-1.jakerob.pro"
}

resource "cloudflare_dns_record" "pbj-node-7" {
  name    = "pbj-node-7.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.205"
}

resource "cloudflare_dns_record" "pbj-node-7-v6" {
  name    = "pbj-node-7.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "AAAA"
  content = "2601:640:8000:a8f0:fe9b:6ec:5908:f793"
}

resource "cloudflare_dns_record" "homeassistant" {
  name    = "homeassistant.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-node-7.jakerob.pro"
}

resource "cloudflare_dns_record" "slc1-node-3-vpn" {
  name    = "slc1-node-3.vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.95.11.23"
}

/* Aliases */

resource "cloudflare_dns_record" "proxmox-pbj-cname" {
  name    = "proxmox.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-hv-1.jakerob.pro"
}

/* Services */

resource "cloudflare_dns_record" "pbj_catch_all" {
  name    = "*.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "truenas-pbj" {
  name    = "truenas.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-storage-1.jakerob.pro"
}

////////////////////////
//     Email          //
////////////////////////

resource "cloudflare_dns_record" "DMARC" {
  name    = "_dmarc.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;\""
}

resource "cloudflare_dns_record" "resend" {
  name    = "resend._domainkey.accounts.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB\""
}

resource "cloudflare_dns_record" "send" {
  name    = "send.accounts.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:amazonses.com ~all\""
}


resource "cloudflare_dns_record" "MX_3" {
  name     = "jakerob.pro"
  zone_id  = cloudflare_zone.jakerob_pro.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx3.zoho.com"
  priority = 50
}

resource "cloudflare_dns_record" "MX_2" {
  name     = "jakerob.pro"
  zone_id  = cloudflare_zone.jakerob_pro.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx2.zoho.com"
  priority = 20
}

resource "cloudflare_dns_record" "MX_1" {
  name     = "jakerob.pro"
  zone_id  = cloudflare_zone.jakerob_pro.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx.zoho.com"
  priority = 10
}

resource "cloudflare_dns_record" "SPF" {
  name    = "jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:zohomail.com ~all\""
}

resource "cloudflare_dns_record" "zoho-verification" {
  name    = "jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"zoho-verification=zb40496945.zmverify.zoho.com\""
}

resource "cloudflare_dns_record" "zmail-_domainkey" {
  name    = "zmail._domainkey.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC496gruPELcl8TYnoCGcw4CVgVBX8iSaHwNL5VurwSY7WpQxbdRsBGObnnIsVVmV8jlSR7Of81W/zAuM4gOe/y+J667bJ3tKeuz0FImKjuMBVn0nSWKB4qy7Y0T9b2iTD3zZH1IzrQlzMsF1oLidk+5ch+MUH2W2TEa0aBQaP6IwIDAQAB\""
}

resource "cloudflare_dns_record" "sgu1-node-1" {
  name    = "sgu1-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.59.194"
}

resource "cloudflare_dns_record" "sgu1-hv-1" {
  name    = "sgu1-hv-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.59.16"
}

resource "cloudflare_dns_record" "sgu1-pi-1" {
  name    = "sgu1-pi-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.59.162"
}

resource "cloudflare_dns_record" "slc1-node-1" {
  name    = "slc1-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.36"
}

resource "cloudflare_dns_record" "slc1-node-2" {
  name    = "slc1-node-2.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.92"
}

resource "cloudflare_dns_record" "slc1-pi-1" {
  name    = "slc1-pi-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.73"
}

resource "cloudflare_dns_record" "slc1-node-3" {
  name    = "slc1-node-3.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.133"
}

resource "cloudflare_dns_record" "slc1-nut-1" {
  name    = "slc1-nut-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.28"
}

resource "cloudflare_dns_record" "slc1-hv-1" {
  name    = "slc1-hv-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.34"
}

resource "cloudflare_dns_record" "slc1-storage-node-1" {
  name    = "slc1-storage-node-1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.27"
}

resource "cloudflare_dns_record" "api-spotify-iad1" {
  name    = "api.spotify.iad1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "pocket-id-pbj" {
  name    = "pocket-id.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "cdn" {
  name    = "cdn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
  comment = "Will use traefik to push different subdomains to different places"
}

resource "cloudflare_dns_record" "cdn-ppr" {
  name    = "cdn-ppr.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "celia" {
  name    = "celia.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "homebox" {
  name    = "homebox.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-iad1" {
  name    = "*.iad1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "secret-santa" {
  name    = "secret-santa.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "it-tools" {
  name    = "it-tools.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "convertx" {
  name    = "convert.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "mealie" {
  name    = "mealie.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "minecraft" {
  name    = "minecraft.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "factorio" {
  name    = "factorio.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "factorio_srv" {
  name     = "_factorio._udp.factorio.jakerob.pro"
  zone_id  = cloudflare_zone.jakerob_pro.id
  proxied  = false
  ttl      = 1
  priority = 0
  type     = "SRV"
  data = {
    port     = 34197
    priority = 0
    weight   = 0
    target   = "factorio.jakerob.pro"
  }
}

resource "cloudflare_dns_record" "nextjsrenderingdemo-fullcf" {
  name    = "nextjsrenderingdemo-fullcf.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
  comment = "Go fully through the cloudflare cache for everything"
}

resource "cloudflare_dns_record" "photos" {
  name    = "photos.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "pma2-iad1vpn" {
  name    = "pma2.iad1vpn.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-vpn-node-2"
}

resource "cloudflare_dns_record" "proxmox-sgu1" {
  name    = "proxmox.sgu1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "sgu1-hv-1.jakerob.pro"
}

resource "cloudflare_dns_record" "proxmox-slc1" {
  name    = "proxmox.slc1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-hv-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-sgu1" {
  name    = "*.sgu1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "sgu1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-slc1" {
  name    = "*.slc1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-node-3.jakerob.pro"
}

resource "cloudflare_dns_record" "split" {
  name    = "split.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "cname.vercel-dns.com"
}

resource "cloudflare_dns_record" "spotify" {
  name    = "spotify.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "truenas-slc1" {
  name    = "truenas.slc1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-storage-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel-pbj" {
  name    = "whoami-tunnel.pbj.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel-slc1" {
  name    = "whoami-tunnel.slc1.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "wordpress" {
  name    = "wordpress.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}


resource "cloudflare_dns_record" "_atproto" {
  name    = "_atproto.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"did=did:plc:frwgjj3qjp3cc6qvsfmtiloo\""
  comment = "Blue Sky"
}

resource "cloudflare_dns_record" "pbj-node-5" {
  name    = "pbj-node-5.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.114"
}

resource "cloudflare_dns_record" "pbj-node-6" {
  name    = "pbj-node-6.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.89"
}

resource "cloudflare_dns_record" "pbj-kubernetes-catch-all" {
  name    = "*.pbj-k.jakerob.pro"
  zone_id = cloudflare_zone.jakerob_pro.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "pbj-node-6.jakerob.pro"
}
