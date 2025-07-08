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
  content = "76.76.21.21"
}

resource "cloudflare_dns_record" "jakerob_www_record" {
  name    = "www.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
}

////////////////////////
//    Public Apps     //
////////////////////////

resource "cloudflare_dns_record" "jellyfin" {
  name    = "jellyfin.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "karakeep" {
  name    = "karakeep.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "calibre" {
  name    = "calibre.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
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
  content = "129.158.205.205"
}

resource "cloudflare_dns_record" "iad1-node-3" {
  name    = "iad1-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "150.136.240.69"
}

resource "cloudflare_dns_record" "iad1_catch_all" {
  name    = "*.iad1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
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
  content = "100.109.65.68"
}

resource "cloudflare_dns_record" "iad1-vpn-node-2" {
  name    = "iad1-vpn-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.107.169.91"
}

resource "cloudflare_dns_record" "iad1-vpn-node-3" {
  name    = "iad1-vpn-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.70.105.44"
}

resource "cloudflare_dns_record" "iad1_vpn_catch_all" {
  name    = "*.iad1vpn.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-vpn-node-1.jakerob.pro"
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
  content = "192.168.42.10"
}

resource "cloudflare_dns_record" "lhr1-proxmox-1" {
  name    = "lhr1-proxmox-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.10"
}

resource "cloudflare_dns_record" "lhr1-node-2" {
  name    = "lhr1-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.3"
}

resource "cloudflare_dns_record" "lhr1-node-4" {
  name    = "lhr1-node-4.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.156"
}

resource "cloudflare_dns_record" "lhr1_catch_all" {
  name    = "*.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "lhr1-node-4_catch_all" {
  name    = "*.lhr1-4.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-node-4.jakerob.pro"
}

resource "cloudflare_dns_record" "proxmox-lhr1-cname" {
  name    = "proxmox.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-proxmox-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "lhr1-dev-1" {
  name    = "lhr1-dev-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.211"
}

resource "cloudflare_dns_record" "lhr1-node-1" {
  name    = "lhr1-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.16"
}

resource "cloudflare_dns_record" "lhr1-vm-1" {
  name    = "lhr1-vm-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.16"
}

resource "cloudflare_dns_record" "lhr1-node-3" {
  name    = "lhr1-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.13"
}

resource "cloudflare_dns_record" "lhr1-nut-1" {
  name    = "lhr1-nut-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.12"
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
  content = "v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;"
}

resource "cloudflare_dns_record" "resend" {
  name    = "resend._domainkey.accounts.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB"
}

resource "cloudflare_dns_record" "send" {
  name    = "send.accounts.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "v=spf1 include:amazonses.com ~all"
}

resource "cloudflare_dns_record" "lhr1-storage-node-1" {
  name    = "lhr1-storage-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.14"
}

resource "cloudflare_dns_record" "lhr1-vpn-node-1" {
  name    = "lhr1-vpn-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.89.27.79"
}

resource "cloudflare_dns_record" "pihole-lhr1" {
  name    = "pihole.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.2"
}

resource "cloudflare_dns_record" "lhr1-pi-1" {
  name    = "lhr1-pi-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.42.2"
}

resource "cloudflare_dns_record" "sgu1-node-1" {
  name    = "sgu1-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.59.194"
}

resource "cloudflare_dns_record" "sgu1-proxmox-node-1" {
  name    = "sgu1-proxmox-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.59.16"
}

resource "cloudflare_dns_record" "slc1-node-1" {
  name    = "slc1-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.36"
}

resource "cloudflare_dns_record" "slc1-node-2" {
  name    = "slc1-node-2.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.92"
}

resource "cloudflare_dns_record" "slc1-node-3" {
  name    = "slc1-node-3.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.133"
}

resource "cloudflare_dns_record" "slc1-nut-1" {
  name    = "slc1-nut-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.28"
}

resource "cloudflare_dns_record" "slc1-proxmox-node-1" {
  name    = "slc1-proxmox-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.34"
}

resource "cloudflare_dns_record" "slc1-storage-node-1" {
  name    = "slc1-storage-node-1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "192.168.97.27"
}

resource "cloudflare_dns_record" "api-spotify-iad1" {
  name    = "api.spotify.iad1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "authentik-lhr1" {
  name    = "authentik.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "cdn" {
  name    = "cdn.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
  comment = "Will use traefik to push different subdomains to different places"
}

resource "cloudflare_dns_record" "cdn-ppr" {
  name    = "cdn-ppr.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "celia" {
  name    = "celia.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "homebox" {
  name    = "homebox.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-iad1" {
  name    = "*.iad1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "it-tools" {
  name    = "it-tools.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "mealie" {
  name    = "mealie.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "minecraft" {
  name    = "minecraft.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "nextjsrenderingdemo-fullcf" {
  name    = "nextjsrenderingdemo-fullcf.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
  comment = "Go fully through the cloudflare cache for everything"
}

resource "cloudflare_dns_record" "photos" {
  name    = "photos.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "pihole2-lhr1" {
  name    = "pihole2.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-node-2.jakerob.pro"
}

resource "cloudflare_dns_record" "pma2-iad1vpn" {
  name    = "pma2.iad1vpn.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-vpn-node-2"
}

resource "cloudflare_dns_record" "proxmox-sgu1" {
  name    = "proxmox.sgu1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "sgu1-proxmox-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "proxmox-slc1" {
  name    = "proxmox.slc1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-proxmox-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-sgu1" {
  name    = "*.sgu1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "sgu1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "catch_all-slc1" {
  name    = "*.slc1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-node-3.jakerob.pro"
}

resource "cloudflare_dns_record" "split" {
  name    = "split.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "cname.vercel-dns.com"
}

resource "cloudflare_dns_record" "spotify" {
  name    = "spotify.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "truenas-lhr1" {
  name    = "truenas.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-storage-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "truenas-slc1" {
  name    = "truenas.slc1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "slc1-storage-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-lhr1" {
  name    = "whoami.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel2-lhr1" {
  name    = "whoami-tunnel2-lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel3-lhr1" {
  name    = "whoami-tunnel3-lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "lhr1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel-lhr1" {
  name    = "whoami-tunnel-lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "whoami-tunnel-slc1" {
  name    = "whoami-tunnel-slc1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "wordpress" {
  name    = "wordpress.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "iad1-node-1.jakerob.pro"
}

resource "cloudflare_dns_record" "MX_3" {
  name     = "jakerob.pro"
  zone_id  = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx3.zoho.com"
  priority = 50
}

resource "cloudflare_dns_record" "MX_2" {
  name     = "jakerob.pro"
  zone_id  = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx2.zoho.com"
  priority = 20
}

resource "cloudflare_dns_record" "MX_1" {
  name     = "jakerob.pro"
  zone_id  = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx.zoho.com"
  priority = 10
}

resource "cloudflare_dns_record" "_acme-challenge-traefik-tunnel-lhr12" {
  name    = "_acme-challenge.traefik-tunnel.lhr12.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 120
  type    = "TXT"
  content = "cocrI7O8eQTznLTjxNU893UG0hD8mttFUXACE22ne-U"
}

resource "cloudflare_dns_record" "_atproto" {
  name    = "_atproto.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"did=did:plc:frwgjj3qjp3cc6qvsfmtiloo\""
  comment = "Blue Sky"
}

resource "cloudflare_dns_record" "docker-node-2-lhr1" {
  name    = "docker-node-2.lhr1.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 120
  type    = "TXT"
  content = "S4aCW3ZO18lffYiT6b9bv4ZS29UmIGU0hjHNP9vLQOc"
}

resource "cloudflare_dns_record" "SPF" {
  name    = "jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "v=spf1 include:zohomail.com ~all"
}

resource "cloudflare_dns_record" "zoho-verification" {
  name    = "jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "zoho-verification=zb40496945.zmverify.zoho.com"
}

resource "cloudflare_dns_record" "zmail-_domainkey" {
  name    = "zmail._domainkey.jakerob.pro"
  zone_id = "6e98165e20ed0ba1b018f543c6ab4285"
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC496gruPELcl8TYnoCGcw4CVgVBX8iSaHwNL5VurwSY7WpQxbdRsBGObnnIsVVmV8jlSR7Of81W/zAuM4gOe/y+J667bJ3tKeuz0FImKjuMBVn0nSWKB4qy7Y0T9b2iTD3zZH1IzrQlzMsF1oLidk+5ch+MUH2W2TEa0aBQaP6IwIDAQAB"
}
