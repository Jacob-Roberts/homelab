# DNS records for autovation.com, managed as a single for_each resource.
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

    "autovation_apex_record" = {
      name    = "autovation.com"
      type    = "A"
      content = "76.76.21.21"
      ttl     = 1
      proxied = false
      comment = "vercel"
    },
    "autovation_www_record" = {
      name    = "www.autovation.com"
      type    = "CNAME"
      content = "cname.vercel-dns.com"
      ttl     = 1
      proxied = false
    },
    "photos" = {
      name    = "photos.autovation.com"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },
    "pocket-id" = {
      name    = "auth.autovation.com"
      type    = "CNAME"
      content = "iad1-node-1.jakerob.pro"
      ttl     = 1
      proxied = false
    },

    ////////////////////////
    //    Main Records    //
    ////////////////////////

    "bwproxy_autovation" = {
      name    = "bwproxy.autovation.com"
      type    = "A"
      content = "74.122.76.29"
      ttl     = 1
      proxied = false
    },
    "cloud_autovation" = {
      name    = "cloud.autovation.com"
      type    = "A"
      content = "97.117.91.215"
      ttl     = 1
      proxied = false
    },
    "em7586" = {
      name    = "em7586.autovation.com"
      type    = "CNAME"
      content = "u14070584.wl085.sendgrid.net"
      ttl     = 1
      proxied = false
      comment = "sendgrid"
    },
    "googlef26116410a115f1f" = {
      name    = "googlef26116410a115f1f.autovation.com"
      type    = "CNAME"
      content = "google.com"
      ttl     = 1
      proxied = false
      comment = "google gmail verification"
    },
    "s1_domainkey_autovation" = {
      name    = "s1._domainkey.autovation.com"
      type    = "CNAME"
      content = "s1.domainkey.u14070584.wl085.sendgrid.net"
      ttl     = 1
      proxied = false
      comment = "sendgrid verification"
    },
    "s2_domainkey_autovation" = {
      name    = "s2._domainkey.autovation.com"
      type    = "CNAME"
      content = "s2.domainkey.u14070584.wl085.sendgrid.net"
      ttl     = 1
      proxied = false
      comment = "sendgrid"
    },

    ////////////////////////
    //   Email Records    //
    ////////////////////////

    "webmail" = {
      name    = "webmail.autovation.com"
      type    = "CNAME"
      content = "autovation.com"
      ttl     = 1
      proxied = false
    },
    "MX_autovation_2" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "alt2.aspmx.l.google.com"
      ttl      = 1
      proxied  = false
      priority = 5
    },
    "MX_autovation_3" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "aspmx3.googlemail.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "MX_autovation_main" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "aspmx.l.google.com"
      ttl      = 1
      proxied  = false
      priority = 1
    },
    "MX_autovation" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "mail.boxworks.com"
      ttl      = 1
      proxied  = false
      priority = 11
    },
    "MX_autovation_4" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "aspmx4.googlemail.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "MX_autovation_5" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "aspmx5.googlemail.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "MX_autovation_1" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "alt1.aspmx.l.google.com"
      ttl      = 1
      proxied  = false
      priority = 5
    },
    "MX_autovation_main_2" = {
      name     = "autovation.com"
      type     = "MX"
      content  = "aspmx2.googlemail.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "SPF1_autovation" = {
      name    = "autovation.com"
      type    = "TXT"
      content = "\"v=spf1 include:zohomail.com include:_spf.google.com ~all\""
      ttl     = 1
      proxied = false
    },
    "DKIM_autovation" = {
      name    = "google._domainkey.autovation.com"
      type    = "TXT"
      content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmayEOPZ+ojneaEM6YT+rkvv9MA7Kggo/wlObPlUaE5XSWBju6bmmwk7vO7tYNZPgvct88Raop3D6vHOauP4sfsQxIiS+tclNyxSuMkia3K81dmvYzP1Ncys+aoGJgH72DcqiKrbr+AJi7+pIKewxxEdjejrzKbH1A4362lI0KmsXUh0tUpanEtYfGT0oz42TA1z3tA/c4AiWkdM61NIpQKuYN6tfTv7SnbAD3HMSvMOAie6/sWh3XUZKCqr8m6aoewnuFGfPqVF+NcCLrqVObDrZWCVC/Bn3AuFU+iEpjxXmKPEUoEvfgIVJX8t1wHloiuGml4of1d5aPG+A8mhJ9wIDAQAB\""
      ttl     = 1
      proxied = false
    },
    "DKIM_zoho" = {
      name    = "zmail._domainkey"
      type    = "TXT"
      content = "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCR9FPnibMyA/ClrqCrf3LU5pLti0PS01iKtywXHG5gOiUnBPXA6ThD+oUeWKAfo3sH5syq6xVbE0nz7XdZq+pgt8ZAMy9ZTbvKAeSEtZbdvLTm2d6C6mstaeSvjJ74iqcQabTsU3bwQMhWPVQuO2mYjfhxnAq1idfvKhViqdY4/QIDAQAB\""
      ttl     = 1
      proxied = false
    },
    "autovation_com_dmarc" = {
      name    = "_dmarc.autovation.com"
      type    = "TXT"
      content = "\"v=DMARC1;p=reject;rua=mailto:89ca6e8456c24e66ae361369e3648aa5@dmarc-reports.cloudflare.net,rua=mailto:7b7233315f@rua.easydmarc.eu;ruf=mailto:7b7233315f@ruf.easydmarc.eu;fo=1;adkim=s;aspf=s;\""
      ttl     = 1
      proxied = false
    },

    // Resend

    "resend_domain_key" = {
      name    = "resend._domainkey.srv"
      type    = "TXT"
      content = "\"p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7F0zQnrEOxTPgdgtAEh5ndwH5Bevre75iBeL29omZFjJaq3Etq5fGZIufk45uyBGZsMqkfDBQ0qAgukgpKrGxryYRGa2whNhwQ315lX/5xww56MWpeHwgWbKCIgDhZByz1CgKGmWd5V45uUc6qqiTP2SBgH5Ll6WWAU446Hr4PQIDAQAB\""
      ttl     = 1
      proxied = false
    },
    "resend_srv" = {
      name     = "send.srv"
      type     = "MX"
      content  = "feedback-smtp.us-east-1.amazonses.com"
      ttl      = 1
      proxied  = false
      priority = 10
    },
    "resend_srv_txt" = {
      name    = "send.srv"
      type    = "TXT"
      content = "\"v=spf1 include:amazonses.com ~all\""
      ttl     = 1
      proxied = false
    },

    // ZOHO

    "zoho_mail" = {
      name    = "@"
      type    = "TXT"
      content = "\"zoho-verification=zb27101284.zmverify.zoho.com\""
      ttl     = 1
      proxied = false
    },
  }
}
