import dns from "./dns.json";
const util = require("node:util");
const exec = util.promisify(require("node:child_process").exec);

async function createTerraformRecord(
  item,
  domain = "jakerob.pro",
  zoneID = "6e98165e20ed0ba1b018f543c6ab4285"
) {
  let nameID = item.name
    .substring(0, item.name.indexOf(`.${domain}`))
    .replaceAll("*.", "catch_all-")
    .replaceAll(".", "-");
  if (nameID === "") {
    nameID = item.type + `_${domain.replaceAll(".", "_")}`;
  }
  if (item.content == "mx3.zoho.com") {
    nameID = "MX_3";
  } else if (item.content == "mx2.zoho.com") {
    nameID = "MX_2";
  } else if (item.content == "mx.zoho.com") {
    nameID = "MX_1";
  } else if (item.content == "v=spf1 include:zohomail.com ~all") {
    nameID = "SPF";
  } else if (item.content == "zoho-verification=zb40496945.zmverify.zoho.com") {
    nameID = "zoho-verification";
  }
  const cloudflareID = item.id;

  const { stdout, stderr } = await exec(
    `tofu import cloudflare_dns_record.${nameID} ${zoneID}/${cloudflareID}`
  );
  console.log(`stdout: ${stdout}`);
  console.error(`stderr: ${stderr}`);
}

const results = dns.result;
for (let data of results) {
  await createTerraformRecord(data, "autovation.com", "dc32b6130553f5adc9972f7f27b438cf");
}
