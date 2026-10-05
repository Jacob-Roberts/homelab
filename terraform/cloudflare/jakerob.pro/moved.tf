# State migration: each DNS record used to be its own top-level resource
# (cloudflare_dns_record.jellyfin, and so on). They are now instances of a
# single cloudflare_dns_record.records keyed by the same identifier, so each
# one needs a moved block or Terraform would destroy and recreate it.
#
# These become no-ops once they have been applied and may be deleted then.

moved {
  from = cloudflare_dns_record.jakerob_apex_record
  to   = cloudflare_dns_record.records["jakerob_apex_record"]
}

moved {
  from = cloudflare_dns_record.jakerob_www_record
  to   = cloudflare_dns_record.records["jakerob_www_record"]
}

moved {
  from = cloudflare_dns_record.social_signal_vercel
  to   = cloudflare_dns_record.records["social_signal_vercel"]
}

moved {
  from = cloudflare_dns_record.social_signal_api
  to   = cloudflare_dns_record.records["social_signal_api"]
}

moved {
  from = cloudflare_dns_record.jellyfin
  to   = cloudflare_dns_record.records["jellyfin"]
}

moved {
  from = cloudflare_dns_record.karakeep
  to   = cloudflare_dns_record.records["karakeep"]
}

moved {
  from = cloudflare_dns_record.joplin
  to   = cloudflare_dns_record.records["joplin"]
}

moved {
  from = cloudflare_dns_record.calibre
  to   = cloudflare_dns_record.records["calibre"]
}

moved {
  from = cloudflare_dns_record.matrix
  to   = cloudflare_dns_record.records["matrix"]
}

moved {
  from = cloudflare_dns_record.element
  to   = cloudflare_dns_record.records["element"]
}

moved {
  from = cloudflare_dns_record.n8n
  to   = cloudflare_dns_record.records["n8n"]
}

moved {
  from = cloudflare_dns_record.iad1-node-1
  to   = cloudflare_dns_record.records["iad1-node-1"]
}

moved {
  from = cloudflare_dns_record.iad1-node-2
  to   = cloudflare_dns_record.records["iad1-node-2"]
}

moved {
  from = cloudflare_dns_record.iad1-node-3
  to   = cloudflare_dns_record.records["iad1-node-3"]
}

moved {
  from = cloudflare_dns_record.iad1_catch_all
  to   = cloudflare_dns_record.records["iad1_catch_all"]
}

moved {
  from = cloudflare_dns_record.iad1-node-1-vpn
  to   = cloudflare_dns_record.records["iad1-node-1-vpn"]
}

moved {
  from = cloudflare_dns_record.iad1-node-2-vpn
  to   = cloudflare_dns_record.records["iad1-node-2-vpn"]
}

moved {
  from = cloudflare_dns_record.iad1-node-3-vpn
  to   = cloudflare_dns_record.records["iad1-node-3-vpn"]
}

moved {
  from = cloudflare_dns_record.iad1_vpn_catch_all
  to   = cloudflare_dns_record.records["iad1_vpn_catch_all"]
}

moved {
  from = cloudflare_dns_record.pbj-router
  to   = cloudflare_dns_record.records["pbj-router"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-1
  to   = cloudflare_dns_record.records["pbj-hv-1"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-1-v6
  to   = cloudflare_dns_record.records["pbj-hv-1-v6"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-2
  to   = cloudflare_dns_record.records["pbj-hv-2"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-2-v6
  to   = cloudflare_dns_record.records["pbj-hv-2-v6"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-3
  to   = cloudflare_dns_record.records["pbj-hv-3"]
}

moved {
  from = cloudflare_dns_record.pbj-hv-3-v6
  to   = cloudflare_dns_record.records["pbj-hv-3-v6"]
}

moved {
  from = cloudflare_dns_record.pbj-node-1
  to   = cloudflare_dns_record.records["pbj-node-1"]
}

moved {
  from = cloudflare_dns_record.pbj-node-1-v6
  to   = cloudflare_dns_record.records["pbj-node-1-v6"]
}

moved {
  from = cloudflare_dns_record.pbj-node-1-vpn
  to   = cloudflare_dns_record.records["pbj-node-1-vpn"]
}

moved {
  from = cloudflare_dns_record.pbj-pi-1
  to   = cloudflare_dns_record.records["pbj-pi-1"]
}

moved {
  from = cloudflare_dns_record.pbj-pi-1-v6
  to   = cloudflare_dns_record.records["pbj-pi-1-v6"]
}

moved {
  from = cloudflare_dns_record.wildcard-pbj-pi-1
  to   = cloudflare_dns_record.records["wildcard-pbj-pi-1"]
}

moved {
  from = cloudflare_dns_record.pbj-storage-1
  to   = cloudflare_dns_record.records["pbj-storage-1"]
}

moved {
  from = cloudflare_dns_record.pbj-storage-1-v6
  to   = cloudflare_dns_record.records["pbj-storage-1-v6"]
}

moved {
  from = cloudflare_dns_record.pbj-pbs-1
  to   = cloudflare_dns_record.records["pbj-pbs-1"]
}

moved {
  from = cloudflare_dns_record.pbj-pbs-1-v6
  to   = cloudflare_dns_record.records["pbj-pbs-1-v6"]
}

moved {
  from = cloudflare_dns_record.pbs-pbj
  to   = cloudflare_dns_record.records["pbs-pbj"]
}

moved {
  from = cloudflare_dns_record.pbj-node-7
  to   = cloudflare_dns_record.records["pbj-node-7"]
}

moved {
  from = cloudflare_dns_record.pbj-node-7-v6
  to   = cloudflare_dns_record.records["pbj-node-7-v6"]
}

moved {
  from = cloudflare_dns_record.homeassistant
  to   = cloudflare_dns_record.records["homeassistant"]
}

moved {
  from = cloudflare_dns_record.slc1-node-3-vpn
  to   = cloudflare_dns_record.records["slc1-node-3-vpn"]
}

moved {
  from = cloudflare_dns_record.proxmox-pbj-cname
  to   = cloudflare_dns_record.records["proxmox-pbj-cname"]
}

moved {
  from = cloudflare_dns_record.pbj_catch_all
  to   = cloudflare_dns_record.records["pbj_catch_all"]
}

moved {
  from = cloudflare_dns_record.truenas-pbj
  to   = cloudflare_dns_record.records["truenas-pbj"]
}

moved {
  from = cloudflare_dns_record.DMARC
  to   = cloudflare_dns_record.records["DMARC"]
}

moved {
  from = cloudflare_dns_record.resend
  to   = cloudflare_dns_record.records["resend"]
}

moved {
  from = cloudflare_dns_record.send
  to   = cloudflare_dns_record.records["send"]
}

moved {
  from = cloudflare_dns_record.MX_3
  to   = cloudflare_dns_record.records["MX_3"]
}

moved {
  from = cloudflare_dns_record.MX_2
  to   = cloudflare_dns_record.records["MX_2"]
}

moved {
  from = cloudflare_dns_record.MX_1
  to   = cloudflare_dns_record.records["MX_1"]
}

moved {
  from = cloudflare_dns_record.SPF
  to   = cloudflare_dns_record.records["SPF"]
}

moved {
  from = cloudflare_dns_record.zoho-verification
  to   = cloudflare_dns_record.records["zoho-verification"]
}

moved {
  from = cloudflare_dns_record.zmail-_domainkey
  to   = cloudflare_dns_record.records["zmail-_domainkey"]
}

moved {
  from = cloudflare_dns_record.sgu1-node-1
  to   = cloudflare_dns_record.records["sgu1-node-1"]
}

moved {
  from = cloudflare_dns_record.sgu1-hv-1
  to   = cloudflare_dns_record.records["sgu1-hv-1"]
}

moved {
  from = cloudflare_dns_record.sgu1-pi-1
  to   = cloudflare_dns_record.records["sgu1-pi-1"]
}

moved {
  from = cloudflare_dns_record.slc1-node-1
  to   = cloudflare_dns_record.records["slc1-node-1"]
}

moved {
  from = cloudflare_dns_record.slc1-node-2
  to   = cloudflare_dns_record.records["slc1-node-2"]
}

moved {
  from = cloudflare_dns_record.slc1-pi-1
  to   = cloudflare_dns_record.records["slc1-pi-1"]
}

moved {
  from = cloudflare_dns_record.slc1-node-3
  to   = cloudflare_dns_record.records["slc1-node-3"]
}

moved {
  from = cloudflare_dns_record.slc1-nut-1
  to   = cloudflare_dns_record.records["slc1-nut-1"]
}

moved {
  from = cloudflare_dns_record.slc1-hv-1
  to   = cloudflare_dns_record.records["slc1-hv-1"]
}

moved {
  from = cloudflare_dns_record.slc1-storage-node-1
  to   = cloudflare_dns_record.records["slc1-storage-node-1"]
}

moved {
  from = cloudflare_dns_record.api-spotify-iad1
  to   = cloudflare_dns_record.records["api-spotify-iad1"]
}

moved {
  from = cloudflare_dns_record.pocket-id-pbj
  to   = cloudflare_dns_record.records["pocket-id-pbj"]
}

moved {
  from = cloudflare_dns_record.cdn
  to   = cloudflare_dns_record.records["cdn"]
}

moved {
  from = cloudflare_dns_record.cdn-ppr
  to   = cloudflare_dns_record.records["cdn-ppr"]
}

moved {
  from = cloudflare_dns_record.celia
  to   = cloudflare_dns_record.records["celia"]
}

moved {
  from = cloudflare_dns_record.homebox
  to   = cloudflare_dns_record.records["homebox"]
}

moved {
  from = cloudflare_dns_record.secret-santa
  to   = cloudflare_dns_record.records["secret-santa"]
}

moved {
  from = cloudflare_dns_record.it-tools
  to   = cloudflare_dns_record.records["it-tools"]
}

moved {
  from = cloudflare_dns_record.convertx
  to   = cloudflare_dns_record.records["convertx"]
}

moved {
  from = cloudflare_dns_record.mealie
  to   = cloudflare_dns_record.records["mealie"]
}

moved {
  from = cloudflare_dns_record.minecraft
  to   = cloudflare_dns_record.records["minecraft"]
}

moved {
  from = cloudflare_dns_record.factorio
  to   = cloudflare_dns_record.records["factorio"]
}

moved {
  from = cloudflare_dns_record.factorio_srv
  to   = cloudflare_dns_record.records["factorio_srv"]
}

moved {
  from = cloudflare_dns_record.nextjsrenderingdemo-fullcf
  to   = cloudflare_dns_record.records["nextjsrenderingdemo-fullcf"]
}

moved {
  from = cloudflare_dns_record.photos
  to   = cloudflare_dns_record.records["photos"]
}

moved {
  from = cloudflare_dns_record.pma2-iad1vpn
  to   = cloudflare_dns_record.records["pma2-iad1vpn"]
}

moved {
  from = cloudflare_dns_record.proxmox-sgu1
  to   = cloudflare_dns_record.records["proxmox-sgu1"]
}

moved {
  from = cloudflare_dns_record.proxmox-slc1
  to   = cloudflare_dns_record.records["proxmox-slc1"]
}

moved {
  from = cloudflare_dns_record.catch_all-sgu1
  to   = cloudflare_dns_record.records["catch_all-sgu1"]
}

moved {
  from = cloudflare_dns_record.catch_all-slc1
  to   = cloudflare_dns_record.records["catch_all-slc1"]
}

moved {
  from = cloudflare_dns_record.split
  to   = cloudflare_dns_record.records["split"]
}

moved {
  from = cloudflare_dns_record.spotify
  to   = cloudflare_dns_record.records["spotify"]
}

moved {
  from = cloudflare_dns_record.truenas-slc1
  to   = cloudflare_dns_record.records["truenas-slc1"]
}

moved {
  from = cloudflare_dns_record.whoami-tunnel-pbj
  to   = cloudflare_dns_record.records["whoami-tunnel-pbj"]
}

moved {
  from = cloudflare_dns_record.whoami-tunnel-slc1
  to   = cloudflare_dns_record.records["whoami-tunnel-slc1"]
}

moved {
  from = cloudflare_dns_record.wordpress
  to   = cloudflare_dns_record.records["wordpress"]
}

moved {
  from = cloudflare_dns_record._atproto
  to   = cloudflare_dns_record.records["_atproto"]
}

moved {
  from = cloudflare_dns_record.pbj-node-5
  to   = cloudflare_dns_record.records["pbj-node-5"]
}

moved {
  from = cloudflare_dns_record.pbj-node-6
  to   = cloudflare_dns_record.records["pbj-node-6"]
}

moved {
  from = cloudflare_dns_record.pbj-kubernetes-catch-all
  to   = cloudflare_dns_record.records["pbj-kubernetes-catch-all"]
}
