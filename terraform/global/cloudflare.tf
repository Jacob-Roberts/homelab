provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

////////////////////////
//  Vercel Records    //
////////////////////////

resource "cloudflare_record" "terraform_managed_resource_d7dd04751a0ce4fec9a93c28054b6263" {
  name    = "jakerob.pro"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "76.76.21.21"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_129d4277deb9a6e0e4713b8416f449de" {
  name    = "www"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "76.76.21.21"
  zone_id = var.cloudflare_zone_id
}

////////////////////////
//    Cloud Records   //
////////////////////////

resource "cloudflare_record" "terraform_managed_resource_be58b2724028c860cf809cae7367b045" {
  name    = "iad1-node-1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "150.136.144.201"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_e1ea07b4d94a1fde0f0d4f311998d6d2" {
  name    = "iad1-node-2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "129.158.205.205"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_a666b469b4cd3654941c5f09055f6876" {
  name    = "iad1-node-3"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "150.136.240.69"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_678dba86b434029923d4aa39e62394b7" {
  name    = "*.iad1"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "iad1-node-1.jakerob.pro"
  zone_id = var.cloudflare_zone_id
}

////////////////////////
// Cloud VPN Records  //
////////////////////////

resource "cloudflare_record" "terraform_managed_resource_d3aed3a001d9a30edf4a2bf22b09bb7a" {
  name    = "iad1-vpn-node-1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "100.108.112.55"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_886b761c56d612056bb4c23581552fc2" {
  name    = "*.iad1vpn"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "iad1-vpn-node-1.jakerob.pro"
  zone_id = var.cloudflare_zone_id
}

////////////////////////
//     Homelab        //
////////////////////////

resource "cloudflare_record" "terraform_managed_resource_2ccf64b369328fed61e66f150105e242" {
  name    = "lhr1-proxmox-node-1"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "192.168.42.10"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_62223054cc6f14b22f45a3b797e2e2c5" {
  name    = "lhr1-node-2"
  proxied = false
  ttl     = 1
  type    = "A"
  value   = "192.168.42.15"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_cf974556d63574d6fb945ecf04d9d0e6" {
  name    = "*.lhr1"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "lhr1-node-2.jakerob.pro"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_ae656a93eaabac08ce6ce20709ce6f90" {
  name    = "proxmox.lhr1"
  proxied = false
  ttl     = 1
  type    = "CNAME"
  value   = "lhr1-proxmox-node-1.jakerob.pro"
  zone_id = var.cloudflare_zone_id
}

////////////////////////
//     Email          //
////////////////////////

resource "cloudflare_record" "terraform_managed_resource_0cd962e47bda3ed9c7437073ec661c6e" {
  name    = "_dmarc"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=DMARC1;p=reject;rua=mailto:9f5383a0b0@rua.easydmarc.us;ruf=mailto:9f5383a0b0@ruf.easydmarc.us;fo=1;"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_30cd57fce8ef38e533081fe12de27a3c" {
  name    = "resend._domainkey.accounts"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDlMd9zYib1bBHY+6i05IKnqIUDhR25u8FG+XA7pen3x3Rdhtyi1aINvKbwcdRTuididreQJAzmigYPkFupkCAjj3E+Z7axYw7OPVzNFqOUs+nSef49l2PFaN9aTf/61UwAodRF7eFV1c8ZCiYv5ojVEuabofBPCiKOjEF3v9gxwwIDAQAB"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_820fd66aa141f5d30e4c12ff9a423fe2" {
  name    = "send.accounts"
  proxied = false
  ttl     = 1
  type    = "TXT"
  value   = "v=spf1 include:amazonses.com ~all"
  zone_id = var.cloudflare_zone_id
}
