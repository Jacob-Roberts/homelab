# DNS records for wanderinglaine.com, managed as a single for_each resource.
#
# Add or change a record by editing its entry in local.dns_records below.
# The key is the record's identifier: it is what `tofu state list` reports and
# what you pass to ../tofu.sh to apply a subset without touching the rest.
#
# Optional keys (comment, priority, data) may be omitted; they resolve to null.

locals {
  dns_records = {
    "A_wanderinglaine_com" = {
      name    = "wanderinglaine.com"
      type    = "A"
      content = "76.76.21.21"
      ttl     = 1
      proxied = false
    },
    "www" = {
      name    = "www.wanderinglaine.com"
      type    = "A"
      content = "76.76.21.21"
      ttl     = 1
      proxied = false
    },
    "cka-_domainkey" = {
      name    = "cka._domainkey.wanderinglaine.com"
      type    = "CNAME"
      content = "dkim.dm-wdpj8n0d.sg4.convertkit.com"
      ttl     = 1
      proxied = false
    },
    "ckespa" = {
      name    = "ckespa.wanderinglaine.com"
      type    = "CNAME"
      content = "spf.dm-wdpj8n0d.sg4.convertkit.com"
      ttl     = 1
      proxied = false
    },
    "MX_3_wanderinglaine_com" = {
      name     = "wanderinglaine.com"
      type     = "MX"
      content  = "mx3.zoho.eu"
      ttl      = 1
      proxied  = false
      priority = 50
    },
    "MX_2_wanderinglaine_com" = {
      name     = "wanderinglaine.com"
      type     = "MX"
      content  = "mx2.zoho.eu"
      ttl      = 1
      proxied  = false
      priority = 20
    },
    "MX_1_wanderinglaine_com" = {
      name     = "wanderinglaine.com"
      type     = "MX"
      content  = "mx.zoho.eu"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "_dmarc" = {
      name    = "_dmarc.wanderinglaine.com"
      type    = "TXT"
      content = "\"v=DMARC1;p=reject;rua=mailto:544f23ed9c044173bfa3c327ed16532c@dmarc-reports.cloudflare.net,mailto:6c79e277f6@rua.easydmarc.eu;ruf=mailto:6c79e277f6@ruf.easydmarc.eu;fo=1;\""
      ttl     = 1
      proxied = false
    },
    "google-site-verification" = {
      name    = "wanderinglaine.com"
      type    = "TXT"
      content = "\"google-site-verification=XYyg4-GN7j5t4C7aucoRcsLjjQXNfl3VrXdRjTslV3A\""
      ttl     = 1
      proxied = false
    },
    "spf" = {
      name    = "wanderinglaine.com"
      type    = "TXT"
      content = "\"v=spf1 include:zoho.eu -all\""
      ttl     = 1
      proxied = false
    },
    "zoho-verification" = {
      name    = "wanderinglaine.com"
      type    = "TXT"
      content = "\"zoho-verification=zb32876755.zmverify.zoho.eu\""
      ttl     = 1
      proxied = false
    },
    "zmail-_domainkey" = {
      name    = "zmail._domainkey.wanderinglaine.com"
      type    = "TXT"
      content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDMU+xsRAnuqzJvcPh/F9bT+xG2xIAUPqnpxQ+0HfWZokxaTCs2apedcY/+YI8CBAzEYr2AXy2SGazuLfDZ6xOQ0rNZbBTQcdcI0H2uGdeHoaBPK4HOBLnMI5n5oAl2BM6YdtDTocHgvX2JqbL39vjs4lKaWJ8guKNwlPNSDqL7vwIDAQAB\""
      ttl     = 1
      proxied = false
    },
  }
}
