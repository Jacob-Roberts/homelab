# DNS records for jakerob.pro, managed as a single for_each resource.
#
# Add or change a record by editing its entry in local.dns_records below.
# The key is the record's identifier: it is what `tofu state list` reports and
# what you pass to ../tofu.sh to apply a subset without touching the rest.
#
# Optional keys (comment, priority, data) may be omitted; they resolve to null.

locals {
  dns_records = {

    ////////////////////////
    //  Vercel Records    //
    ////////////////////////

    "jakerob_apex_record" = {
      name    = "jakerob.pro"
      type    = "A"
      content = "76.76.21.21"
      ttl     = 1
      proxied = false
    },
    "jakerob_www_record" = {
      name    = "www.jakerob.pro"
      type    = "A"
      content = "76.76.21.21"
      ttl     = 1
      proxied = false
    },
    "social_signal_vercel" = {
      name    = "socialsignal.jakerob.pro"
      type    = "CNAME"
      content = "ccfcc2545bc5cf9f.vercel-dns-017.com"
      ttl     = 1
      proxied = false
    },
    "social_signal_api" = {
      name    = "api.socialsignal.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },

    ////////////////////////
    //    Public Apps     //
    ////////////////////////

    "jellyfin" = {
      name    = "jellyfin.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "karakeep" = {
      name    = "karakeep.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "joplin" = {
      name    = "joplin.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "calibre" = {
      name    = "calibre.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "matrix" = {
      name    = "matrix.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "element" = {
      name    = "element.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "n8n" = {
      name    = "n8n.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },

    ////////////////////////
    //        IAD1        //
    ////////////////////////

    "iad1-node-1" = {
      name    = "iad1-node-1.jakerob.pro"
      type    = "A"
      content = "150.136.144.201"
      ttl     = 1
      proxied = false
    },
    "iad1-node-2" = {
      name    = "iad1-node-2.jakerob.pro"
      type    = "A"
      content = "129.158.205.205"
      ttl     = 1
      proxied = false
    },
    "iad1-node-3" = {
      name    = "iad1-node-3.jakerob.pro"
      type    = "A"
      content = "150.136.240.69"
      ttl     = 1
      proxied = false
    },
    "iad1_catch_all" = {
      name    = "*.iad1.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },

    ////////////////////////
    //      IAD1 VPN      //
    ////////////////////////

    "iad1-node-1-vpn" = {
      name    = "iad1-node-1.vpn.jakerob.pro"
      type    = "A"
      content = "100.107.140.137"
      ttl     = 1
      proxied = false
    },
    "iad1-node-1-vpn-v6" = {
      name    = "iad1-node-1.vpn.jakerob.pro"
      type    = "AAAA"
      content = "fdbd:db6a:5351:2c4:5755:92ff:8b0e:c534"
      ttl     = 1
      proxied = false
    },
    # "iad1-node-2-vpn" = {
    #   name    = "iad1-node-2.vpn.jakerob.pro"
    #   type    = "A"
    #   content = "100.107.169.91"
    #   ttl     = 1
    #   proxied = false
    # },
    # "iad1-node-3-vpn" = {
    #   name    = "iad1-node-3.vpn.jakerob.pro"
    #   type    = "A"
    #   content = "100.70.105.44"
    #   ttl     = 1
    #   proxied = false
    # },
    "iad1_vpn_catch_all" = {
      name    = "*.iad1vpn.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.vpn.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pbj-router" = {
      name    = "pbj-router.jakerob.pro"
      type    = "A"
      content = "192.168.42.1"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-1" = {
      name    = "pbj-hv-1.jakerob.pro"
      type    = "A"
      content = "192.168.42.13"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-1-v6" = {
      name    = "pbj-hv-1.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:c05d:7462:fab:171f"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-2" = {
      name    = "pbj-hv-2.jakerob.pro"
      type    = "A"
      content = "192.168.42.11"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-2-v6" = {
      name    = "pbj-hv-2.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:7fa7:9eef:10bb:1f35"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-3" = {
      name    = "pbj-hv-3.jakerob.pro"
      type    = "A"
      content = "192.168.42.58"
      ttl     = 1
      proxied = false
    },
    "pbj-hv-3-v6" = {
      name    = "pbj-hv-3.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:2c67:da71:4fb2:ce1a"
      ttl     = 1
      proxied = false
    },
    "pbj-node-1" = {
      name    = "pbj-node-1.jakerob.pro"
      type    = "A"
      content = "192.168.42.120"
      ttl     = 1
      proxied = false
    },
    "pbj-node-1-v6" = {
      name    = "pbj-node-1.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:be24:11ff:feea:1964"
      ttl     = 1
      proxied = false
    },
    "pbj-node-1-vpn" = {
      name    = "pbj-node-1.vpn.jakerob.pro"
      type    = "A"
      content = "100.107.80.160"
      ttl     = 1
      proxied = false
    },
    "pbj-node-1-vpn-v6" = {
      name    = "pbj-node-1.vpn.jakerob.pro"
      type    = "AAAA"
      content = "fdbd:db6a:5351:2c4:4c58:8c56:c12c:5498"
      ttl     = 1
      proxied = false
    },
    "pbj-pi-1" = {
      name    = "pbj-pi-1.jakerob.pro"
      type    = "A"
      content = "192.168.42.2"
      ttl     = 1
      proxied = false
    },
    "pbj-pi-1-v6" = {
      name    = "pbj-pi-1.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:9e36:2401:48e8:b782"
      ttl     = 1
      proxied = false
    },
    "wildcard-pbj-pi-1" = {
      name    = "*.pbj-pi-1.jakerob.pro"
      type    = "CNAME"
      content = "pbj-pi-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pbj-storage-1" = {
      name    = "pbj-storage-1.jakerob.pro"
      type    = "A"
      content = "192.168.42.14"
      ttl     = 1
      proxied = false
    },
    "pbj-storage-1-v6" = {
      name    = "pbj-storage-1.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:2e2:69ff:fe7d:3c36"
      ttl     = 1
      proxied = false
    },
    "pbj-pbs-1" = {
      name    = "pbj-pbs-1.jakerob.pro"
      type    = "A"
      content = "192.168.42.19"
      ttl     = 1
      proxied = false
    },
    "pbj-pbs-1-v6" = {
      name    = "pbj-pbs-1.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:2ac6:1eb1:6291:a4fd"
      ttl     = 1
      proxied = false
    },
    "pbs-pbj" = {
      name    = "pbs.pbj.jakerob.pro"
      type    = "CNAME"
      content = "pbj-pbs-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pbj-node-7" = {
      name    = "pbj-node-7.jakerob.pro"
      type    = "A"
      content = "192.168.42.205"
      ttl     = 1
      proxied = false
    },
    "pbj-node-7-v6" = {
      name    = "pbj-node-7.jakerob.pro"
      type    = "AAAA"
      content = "2601:640:8000:a8f0:fe9b:6ec:5908:f793"
      ttl     = 1
      proxied = false
    },
    "homeassistant" = {
      name    = "homeassistant.jakerob.pro"
      type    = "CNAME"
      content = "pbj-node-7.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "slc1-node-3-vpn" = {
      name    = "slc1-node-3.vpn.jakerob.pro"
      type    = "A"
      content = "100.107.184.93"
      ttl     = 1
      proxied = false
    },
    "slc1-node-3-vpn-v6" = {
      name    = "slc1-node-3.vpn.jakerob.pro"
      type    = "AAAA"
      content = "fdbd:db6a:5351:2c4:11e3:6773:f852:32d5"
      ttl     = 1
      proxied = false
    },
    "proxmox-pbj-cname" = {
      name    = "proxmox.pbj.jakerob.pro"
      type    = "CNAME"
      content = "pbj-hv-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pbj_catch_all" = {
      name    = "*.pbj.jakerob.pro"
      type    = "CNAME"
      content = "pbj-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "truenas-pbj" = {
      name    = "truenas.pbj.jakerob.pro"
      type    = "CNAME"
      content = "pbj-storage-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },

    ////////////////////////
    //     Email          //
    ////////////////////////

    "DMARC" = {
      name    = "_dmarc.jakerob.pro"
      type    = "TXT"
      content = "\"v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;\""
      ttl     = 1
      proxied = false
    },
    "resend" = {
      name    = "resend._domainkey.accounts.jakerob.pro"
      type    = "TXT"
      content = "\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB\""
      ttl     = 1
      proxied = false
    },
    "send" = {
      name    = "send.accounts.jakerob.pro"
      type    = "TXT"
      content = "\"v=spf1 include:amazonses.com ~all\""
      ttl     = 1
      proxied = false
    },
    "MX_3" = {
      name     = "jakerob.pro"
      type     = "MX"
      content  = "mx3.zoho.com"
      ttl      = 1
      proxied  = false
      priority = 50
    },
    "MX_2" = {
      name     = "jakerob.pro"
      type     = "MX"
      content  = "mx2.zoho.com"
      ttl      = 1
      proxied  = false
      priority = 20
    },
    "MX_1" = {
      name     = "jakerob.pro"
      type     = "MX"
      content  = "mx.zoho.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "SPF" = {
      name    = "jakerob.pro"
      type    = "TXT"
      content = "\"v=spf1 include:zohomail.com ~all\""
      ttl     = 1
      proxied = false
    },
    "zoho-verification" = {
      name    = "jakerob.pro"
      type    = "TXT"
      content = "\"zoho-verification=zb40496945.zmverify.zoho.com\""
      ttl     = 1
      proxied = false
    },
    "zmail-_domainkey" = {
      name    = "zmail._domainkey.jakerob.pro"
      type    = "TXT"
      content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC496gruPELcl8TYnoCGcw4CVgVBX8iSaHwNL5VurwSY7WpQxbdRsBGObnnIsVVmV8jlSR7Of81W/zAuM4gOe/y+J667bJ3tKeuz0FImKjuMBVn0nSWKB4qy7Y0T9b2iTD3zZH1IzrQlzMsF1oLidk+5ch+MUH2W2TEa0aBQaP6IwIDAQAB\""
      ttl     = 1
      proxied = false
    },
    "sgu1-node-1" = {
      name    = "sgu1-node-1.jakerob.pro"
      type    = "A"
      content = "192.168.59.194"
      ttl     = 1
      proxied = false
    },
    "sgu1-hv-1" = {
      name    = "sgu1-hv-1.jakerob.pro"
      type    = "A"
      content = "192.168.59.16"
      ttl     = 1
      proxied = false
    },
    "sgu1-pi-1" = {
      name    = "sgu1-pi-1.jakerob.pro"
      type    = "A"
      content = "192.168.59.162"
      ttl     = 1
      proxied = false
    },
    "slc1-node-1" = {
      name    = "slc1-node-1.jakerob.pro"
      type    = "A"
      content = "192.168.97.36"
      ttl     = 1
      proxied = false
    },
    "slc1-node-2" = {
      name    = "slc1-node-2.jakerob.pro"
      type    = "A"
      content = "192.168.97.92"
      ttl     = 1
      proxied = false
    },
    "slc1-pi-1" = {
      name    = "slc1-pi-1.jakerob.pro"
      type    = "A"
      content = "192.168.97.73"
      ttl     = 1
      proxied = false
    },
    "slc1-node-3" = {
      name    = "slc1-node-3.jakerob.pro"
      type    = "A"
      content = "192.168.97.133"
      ttl     = 1
      proxied = false
    },
    "slc1-nut-1" = {
      name    = "slc1-nut-1.jakerob.pro"
      type    = "A"
      content = "192.168.97.28"
      ttl     = 1
      proxied = false
    },
    "slc1-hv-1" = {
      name    = "slc1-hv-1.jakerob.pro"
      type    = "A"
      content = "192.168.97.34"
      ttl     = 1
      proxied = false
    },
    "slc1-storage-node-1" = {
      name    = "slc1-storage-node-1.jakerob.pro"
      type    = "A"
      content = "192.168.97.27"
      ttl     = 1
      proxied = false
    },
    "api-spotify-iad1" = {
      name    = "api.spotify.iad1.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pocket-id-pbj" = {
      name    = "pocket-id.pbj.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "cdn" = {
      name    = "cdn.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = true
      comment = "Will use traefik to push different subdomains to different places"
    },
    "cdn-ppr" = {
      name    = "cdn-ppr.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = true
    },
    "celia" = {
      name    = "celia.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "homebox" = {
      name    = "homebox.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "secret-santa" = {
      name    = "secret-santa.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "it-tools" = {
      name    = "it-tools.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "convertx" = {
      name    = "convert.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "mealie" = {
      name    = "mealie.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "minecraft" = {
      name    = "minecraft.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "factorio" = {
      name    = "factorio.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "factorio_srv" = {
      name     = "_factorio._udp.factorio.jakerob.pro"
      type     = "SRV"
      ttl      = 1
      proxied  = false
      priority = 0
      data = {
        port     = 34197
        priority = 0
        weight   = 0
        target   = "factorio.jakerob.pro"
      }
    },
    "nextjsrenderingdemo-fullcf" = {
      name    = "nextjsrenderingdemo-fullcf.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = true
      comment = "Go fully through the cloudflare cache for everything"
    },
    "photos" = {
      name    = "photos.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pma2-iad1vpn" = {
      name    = "pma2.iad1vpn.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-2.vpn.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "proxmox-sgu1" = {
      name    = "proxmox.sgu1.jakerob.pro"
      type    = "CNAME"
      content = "sgu1-hv-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "proxmox-slc1" = {
      name    = "proxmox.slc1.jakerob.pro"
      type    = "CNAME"
      content = "slc1-hv-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "catch_all-sgu1" = {
      name    = "*.sgu1.jakerob.pro"
      type    = "CNAME"
      content = "sgu1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "catch_all-slc1" = {
      name    = "*.slc1.jakerob.pro"
      type    = "CNAME"
      content = "slc1-node-3.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "split" = {
      name    = "split.jakerob.pro"
      type    = "CNAME"
      content = "cname.vercel-dns.com"
      ttl     = 1
      proxied = false
    },
    "spotify" = {
      name    = "spotify.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "truenas-slc1" = {
      name    = "truenas.slc1.jakerob.pro"
      type    = "CNAME"
      content = "slc1-storage-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "whoami-tunnel-pbj" = {
      name    = "whoami-tunnel.pbj.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "whoami-tunnel-slc1" = {
      name    = "whoami-tunnel.slc1.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "wordpress" = {
      name    = "wordpress.jakerob.pro"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "_atproto" = {
      name    = "_atproto.jakerob.pro"
      type    = "TXT"
      content = "\"did=did:plc:frwgjj3qjp3cc6qvsfmtiloo\""
      ttl     = 1
      proxied = false
      comment = "Blue Sky"
    },
    "pbj-node-5" = {
      name    = "pbj-node-5.jakerob.pro"
      type    = "A"
      content = "192.168.42.114"
      ttl     = 1
      proxied = false
    },
    "pbj-node-6" = {
      name    = "pbj-node-6.jakerob.pro"
      type    = "A"
      content = "192.168.42.89"
      ttl     = 1
      proxied = false
    },
    "pbj-kubernetes-catch-all" = {
      name    = "*.pbj-k.jakerob.pro"
      type    = "CNAME"
      content = "pbj-node-6.jakerob.pro"
      ttl     = 1
      proxied = false
    },
  }
}
