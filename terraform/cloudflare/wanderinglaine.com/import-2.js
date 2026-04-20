import dns from "./dns.json";
import { createTerraformRecord } from "../import-2.js";

const results = dns.result;
for (let data of results) {
  await createTerraformRecord(
    data,
    "./dns.tf",
    "wanderinglaine.com",
    "wanderinglaine_com",
  );
}
