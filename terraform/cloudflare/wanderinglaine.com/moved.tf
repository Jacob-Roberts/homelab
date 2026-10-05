# State migration: each DNS record used to be its own top-level resource
# (cloudflare_dns_record.jellyfin, and so on). They are now instances of a
# single cloudflare_dns_record.records keyed by the same identifier, so each
# one needs a moved block or Terraform would destroy and recreate it.
#
# These become no-ops once they have been applied and may be deleted then.

moved {
  from = cloudflare_dns_record.A_wanderinglaine_com
  to   = cloudflare_dns_record.records["A_wanderinglaine_com"]
}

moved {
  from = cloudflare_dns_record.www
  to   = cloudflare_dns_record.records["www"]
}

moved {
  from = cloudflare_dns_record.cka-_domainkey
  to   = cloudflare_dns_record.records["cka-_domainkey"]
}

moved {
  from = cloudflare_dns_record.ckespa
  to   = cloudflare_dns_record.records["ckespa"]
}

moved {
  from = cloudflare_dns_record.MX_3_wanderinglaine_com
  to   = cloudflare_dns_record.records["MX_3_wanderinglaine_com"]
}

moved {
  from = cloudflare_dns_record.MX_2_wanderinglaine_com
  to   = cloudflare_dns_record.records["MX_2_wanderinglaine_com"]
}

moved {
  from = cloudflare_dns_record.MX_1_wanderinglaine_com
  to   = cloudflare_dns_record.records["MX_1_wanderinglaine_com"]
}

moved {
  from = cloudflare_dns_record._dmarc
  to   = cloudflare_dns_record.records["_dmarc"]
}

moved {
  from = cloudflare_dns_record.google-site-verification
  to   = cloudflare_dns_record.records["google-site-verification"]
}

moved {
  from = cloudflare_dns_record.spf
  to   = cloudflare_dns_record.records["spf"]
}

moved {
  from = cloudflare_dns_record.zoho-verification
  to   = cloudflare_dns_record.records["zoho-verification"]
}

moved {
  from = cloudflare_dns_record.zmail-_domainkey
  to   = cloudflare_dns_record.records["zmail-_domainkey"]
}
