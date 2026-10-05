resource "cloudflare_zone" "wanderinglaine_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "wanderinglaine.com"
  type = "full"
}

# Every DNS record in this zone. The records themselves live in records.tf.
# moved.tf maps the previous one-resource-per-record addresses onto this one.
resource "cloudflare_dns_record" "records" {
  for_each = local.dns_records

  zone_id = cloudflare_zone.wanderinglaine_com.id
  name    = each.value.name
  type    = each.value.type

  ttl     = each.value.ttl
  proxied = each.value.proxied

  # Optional keys. try() is required, not stylistic: for_each keeps each
  # entry's own object type, so an entry without `data` has no such attribute
  # to read and each.value.data would be a hard error rather than null.
  content  = try(each.value.content, null)
  comment  = try(each.value.comment, null)
  priority = try(each.value.priority, null)
  data     = try(each.value.data, null)
}
