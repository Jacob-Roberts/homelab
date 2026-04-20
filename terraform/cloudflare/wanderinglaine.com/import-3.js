import { tofuImport } from "../import-3.js";
import dns from "./dns.json";

const results = dns.result;
for (let data of results) {
  try {
  await tofuImport(data, "wanderinglaine.com", "3aa16e0a1cc88acde128e2ba0d2766b0");
  } catch (error) {
    console.error(error);
  }
}