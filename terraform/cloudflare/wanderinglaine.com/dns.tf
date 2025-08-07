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
