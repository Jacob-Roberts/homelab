resource "cloudflare_zone" "autovation_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "autovation.com"
  type = "full"
}

////////////////////////
//  Examples          //
////////////////////////

// Only required options
# resource "cloudflare_dns_record" "my_main_record" {
#   name    = "autovation.com"
#   proxied = false
#   ttl     = 1 // 1 Means "automatic"
#   type    = "A"
#   zone_id = cloudflare_zone.autovation_com.id
#   content   = "76.76.21.21"
# }

// All possible options
# resource "cloudflare_dns_record" "example_dns_record" {
#   zone_id = cloudflare_zone.autovation_com.id
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

resource "cloudflare_dns_record" "autovation_apex_record" {
  name    = "autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "76.76.21.21"
  comment = "vercel"
}

resource "cloudflare_dns_record" "autovation_www_record" {
  name    = "www.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "cname.vercel-dns.com"
}

////////////////////////
//    Main Records    //
////////////////////////

resource "cloudflare_dns_record" "bwproxy_autovation" {
  name    = "bwproxy.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "74.122.76.29"
}

resource "cloudflare_dns_record" "cloud_autovation" {
  name    = "cloud.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "A"
  content = "97.117.91.215"
}

resource "cloudflare_dns_record" "em7586" {
  name    = "em7586.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "u14070584.wl085.sendgrid.net"
  comment = "sendgrid"
}

resource "cloudflare_dns_record" "googlef26116410a115f1f" {
  name    = "googlef26116410a115f1f.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "google.com"
  comment = "google gmail verification"
}

resource "cloudflare_dns_record" "photos_autovation" {
  name    = "photos.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "bwproxy.autovation.com"
}

resource "cloudflare_dns_record" "s1_domainkey_autovation" {
  name    = "s1._domainkey.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "s1.domainkey.u14070584.wl085.sendgrid.net"
  comment = "sendgrid verification"
}

resource "cloudflare_dns_record" "s2_domainkey_autovation" {
  name    = "s2._domainkey.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "s2.domainkey.u14070584.wl085.sendgrid.net"
  comment = "sendgrid"
}

////////////////////////
//   Email Records    //
////////////////////////

resource "cloudflare_dns_record" "webmail" {
  name    = "webmail.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "CNAME"
  content = "autovation.com"
}

resource "cloudflare_dns_record" "MX_autovation_2" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "alt2.aspmx.l.google.com"
  priority = 5
}

resource "cloudflare_dns_record" "MX_autovation_3" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "aspmx3.googlemail.com"
  priority = 10
}

resource "cloudflare_dns_record" "MX_autovation_main" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "aspmx.l.google.com"
  priority = 1
}

resource "cloudflare_dns_record" "MX_autovation" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "mail.boxworks.com"
  priority = 11
}

resource "cloudflare_dns_record" "MX_autovation_4" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "aspmx4.googlemail.com"
  priority = 10
}

resource "cloudflare_dns_record" "MX_autovation_5" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "aspmx5.googlemail.com"
  priority = 10
}

resource "cloudflare_dns_record" "MX_autovation_1" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "alt1.aspmx.l.google.com"
  priority = 5
}

resource "cloudflare_dns_record" "MX_autovation_main_2" {
  name     = "autovation.com"
  zone_id  = cloudflare_zone.autovation_com.id
  proxied  = false
  ttl      = 1
  type     = "MX"
  content  = "aspmx2.googlemail.com"
  priority = 10
}

resource "cloudflare_dns_record" "SPF1_autovation" {
  name    = "autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com ~all\""
}

resource "cloudflare_dns_record" "DKIM_autovation" {
  name    = "google._domainkey.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmayEOPZ+ojneaEM6YT+rkvv9MA7Kggo/wlObPlUaE5XSWBju6bmmwk7vO7tYNZPgvct88Raop3D6vHOauP4sfsQxIiS+tclNyxSuMkia3K81dmvYzP1Ncys+aoGJgH72DcqiKrbr+AJi7+pIKewxxEdjejrzKbH1A4362lI0KmsXUh0tUpanEtYfGT0oz42TA1z3tA/c4AiWkdM61NIpQKuYN6tfTv7SnbAD3HMSvMOAie6/sWh3XUZKCqr8m6aoewnuFGfPqVF+NcCLrqVObDrZWCVC/Bn3AuFU+iEpjxXmKPEUoEvfgIVJX8t1wHloiuGml4of1d5aPG+A8mhJ9wIDAQAB\""
}

resource "cloudflare_dns_record" "autovation_com_dmarc" {
  name    = "_dmarc.autovation.com"
  zone_id = cloudflare_zone.autovation_com.id
  proxied = false
  ttl     = 1
  type    = "TXT"
  content   = "\"v=DMARC1;p=quarantine;rua=mailto:7b7233315f@rua.easydmarc.eu;ruf=mailto:7b7233315f@ruf.easydmarc.eu;fo=1;\""
}
