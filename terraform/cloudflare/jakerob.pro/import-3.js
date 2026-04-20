import { tofuImport } from "../import-3.js";
import dns from "./dns.json";

const results = dns.result;
for (let data of results) {
  try {
  await tofuImport(data, "jakerob.pro", "6e98165e20ed0ba1b018f543c6ab4285");
  } catch (error) {
    console.error(error);
  }
}