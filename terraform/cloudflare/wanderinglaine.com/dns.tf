resource "cloudflare_zone" "wanderinglaine_com" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "wanderinglaine.com"
  type = "full"
}

locals {
  # Appended to every record's comment so it shows up in the Cloudflare
  # dashboard, making it obvious that a hand edit there will be reverted on the
  # next apply. A record that already has a note keeps it, with the marker added
  # after it. Cloudflare caps a comment at 100 characters on Free plans (500 on
  # paid ones), so keep per-record notes short.
  marker = "managed by terraform"

  record_comments = {
    for key, record in local.dns_records :
    key => join(" | ", compact([try(record.comment, ""), local.marker]))
  }
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
  comment  = local.record_comments[each.key]
  priority = try(each.value.priority, null)
  data     = try(each.value.data, null)
}
