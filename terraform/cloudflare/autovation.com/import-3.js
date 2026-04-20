import { tofuImport } from "../import-3.js";
import dns from "./dns.json";

const results = dns.result;
for (let data of results) {
  try {
  await tofuImport(data, "autovation.com", "dc32b6130553f5adc9972f7f27b438cf");
  } catch (error) {
    console.error(error);
  }
}
