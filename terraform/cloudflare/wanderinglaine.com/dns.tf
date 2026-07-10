resource "cloudflare_zone" "wanderinglaine_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "wanderinglaine.com"
  type = "full"
}

////////////////////////
//  Examples          //
////////////////////////

// Only required options
# resource "cloudflare_dns_record" "my_main_record" {
#   name    = "wanderinglaine.com"
#   proxied = false
#   ttl     = 1 // 1 Means "automatic"
#   type    = "A"
#   zone_id = cloudflare_zone.wanderinglaine_com.id
#   content   = "76.76.21.21"
# }

// All possible options
# resource "cloudflare_dns_record" "example_dns_record" {
#   zone_id = cloudflare_zone.wanderinglaine_com.id
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

resource "cloudflare_dns_record" "A_wanderinglaine_com" {
  name    = "wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
}

resource "cloudflare_dns_record" "www" {
  name    = "www.wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
}

resource "cloudflare_dns_record" "cka-_domainkey" {
  name    = "cka._domainkey.wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "dkim.dm-wdpj8n0d.sg4.convertkit.com"
}

resource "cloudflare_dns_record" "ckespa" {
  name    = "ckespa.wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "spf.dm-wdpj8n0d.sg4.convertkit.com"
}

resource "cloudflare_dns_record" "MX_3_wanderinglaine_com" {
  name     = "wanderinglaine.com"
  zone_id  = cloudflare_zone.wanderinglaine_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx3.zoho.eu"
  priority = 50
}

resource "cloudflare_dns_record" "MX_2_wanderinglaine_com" {
  name     = "wanderinglaine.com"
  zone_id  = cloudflare_zone.wanderinglaine_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx2.zoho.eu"
  priority = 20
}

resource "cloudflare_dns_record" "MX_1_wanderinglaine_com" {
  name     = "wanderinglaine.com"
  zone_id  = cloudflare_zone.wanderinglaine_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mx.zoho.eu"
  priority = 10
}

resource "cloudflare_dns_record" "_dmarc" {
  name    = "_dmarc.wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DMARC1;p=reject;rua=mailto:544f23ed9c044173bfa3c327ed16532c@dmarc-reports.cloudflare.net,mailto:6c79e277f6@rua.easydmarc.eu;ruf=mailto:6c79e277f6@ruf.easydmarc.eu;fo=1;\""
}

resource "cloudflare_dns_record" "google-site-verification" {
  name    = "wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"google-site-verification=XYyg4-GN7j5t4C7aucoRcsLjjQXNfl3VrXdRjTslV3A\""
}

resource "cloudflare_dns_record" "spf" {
  name    = "wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:zoho.eu -all\""
}

resource "cloudflare_dns_record" "zoho-verification" {
  name    = "wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"zoho-verification=zb32876755.zmverify.zoho.eu\""
}

resource "cloudflare_dns_record" "zmail-_domainkey" {
  name    = "zmail._domainkey.wanderinglaine.com"
  zone_id = cloudflare_zone.wanderinglaine_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDMU+xsRAnuqzJvcPh/F9bT+xG2xIAUPqnpxQ+0HfWZokxaTCs2apedcY/+YI8CBAzEYr2AXy2SGazuLfDZ6xOQ0rNZbBTQcdcI0H2uGdeHoaBPK4HOBLnMI5n5oAl2BM6YdtDTocHgvX2JqbL39vjs4lKaWJ8guKNwlPNSDqL7vwIDAQAB\""
}
