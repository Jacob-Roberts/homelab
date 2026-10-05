# State migration: each DNS record used to be its own top-level resource
# (cloudflare_dns_record.jellyfin, and so on). They are now instances of a
# single cloudflare_dns_record.records keyed by the same identifier, so each
# one needs a moved block or Terraform would destroy and recreate it.
#
# These become no-ops once they have been applied and may be deleted then.

moved {
  from = cloudflare_dns_record.autovation_apex_record
  to   = cloudflare_dns_record.records["autovation_apex_record"]
}

moved {
  from = cloudflare_dns_record.autovation_www_record
  to   = cloudflare_dns_record.records["autovation_www_record"]
}

moved {
  from = cloudflare_dns_record.photos
  to   = cloudflare_dns_record.records["photos"]
}

moved {
  from = cloudflare_dns_record.pocket-id
  to   = cloudflare_dns_record.records["pocket-id"]
}

moved {
  from = cloudflare_dns_record.bwproxy_autovation
  to   = cloudflare_dns_record.records["bwproxy_autovation"]
}

moved {
  from = cloudflare_dns_record.cloud_autovation
  to   = cloudflare_dns_record.records["cloud_autovation"]
}

moved {
  from = cloudflare_dns_record.em7586
  to   = cloudflare_dns_record.records["em7586"]
}

moved {
  from = cloudflare_dns_record.googlef26116410a115f1f
  to   = cloudflare_dns_record.records["googlef26116410a115f1f"]
}

moved {
  from = cloudflare_dns_record.s1_domainkey_autovation
  to   = cloudflare_dns_record.records["s1_domainkey_autovation"]
}

moved {
  from = cloudflare_dns_record.s2_domainkey_autovation
  to   = cloudflare_dns_record.records["s2_domainkey_autovation"]
}

moved {
  from = cloudflare_dns_record.webmail
  to   = cloudflare_dns_record.records["webmail"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_2
  to   = cloudflare_dns_record.records["MX_autovation_2"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_3
  to   = cloudflare_dns_record.records["MX_autovation_3"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_main
  to   = cloudflare_dns_record.records["MX_autovation_main"]
}

moved {
  from = cloudflare_dns_record.MX_autovation
  to   = cloudflare_dns_record.records["MX_autovation"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_4
  to   = cloudflare_dns_record.records["MX_autovation_4"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_5
  to   = cloudflare_dns_record.records["MX_autovation_5"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_1
  to   = cloudflare_dns_record.records["MX_autovation_1"]
}

moved {
  from = cloudflare_dns_record.MX_autovation_main_2
  to   = cloudflare_dns_record.records["MX_autovation_main_2"]
}

moved {
  from = cloudflare_dns_record.SPF1_autovation
  to   = cloudflare_dns_record.records["SPF1_autovation"]
}

moved {
  from = cloudflare_dns_record.DKIM_autovation
  to   = cloudflare_dns_record.records["DKIM_autovation"]
}

moved {
  from = cloudflare_dns_record.DKIM_zoho
  to   = cloudflare_dns_record.records["DKIM_zoho"]
}

moved {
  from = cloudflare_dns_record.autovation_com_dmarc
  to   = cloudflare_dns_record.records["autovation_com_dmarc"]
}

moved {
  from = cloudflare_dns_record.resend_domain_key
  to   = cloudflare_dns_record.records["resend_domain_key"]
}

moved {
  from = cloudflare_dns_record.resend_srv
  to   = cloudflare_dns_record.records["resend_srv"]
}

moved {
  from = cloudflare_dns_record.resend_srv_txt
  to   = cloudflare_dns_record.records["resend_srv_txt"]
}

moved {
  from = cloudflare_dns_record.zoho_mail
  to   = cloudflare_dns_record.records["zoho_mail"]
}
