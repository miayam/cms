#!/usr/bin/env node

const crypto = require("crypto");

console.log("🔐 Generating secure keys for your CMS setup...\n");

// Stack Auth Keys
console.log("=== STACK AUTH KEYS ===");
console.log(
  "STACK_SECRET_SERVER_KEY=",
  generateBase64Key(32)
    .replace(/[+/]/g, (c) => (c === "+" ? "-" : "_"))
    .replace(/=/g, ""),
);
console.log("STACK_SVIX_API_KEY=sv-" + crypto.randomBytes(16).toString("hex"));
console.log("SVIX_JWT_SECRET=sv-" + crypto.randomBytes(32).toString("hex"));

// Database password
console.log("\n=== DATABASE PASSWORD ===");
console.log("DATABASE_PASSWORD=", generateAlphanumeric(24));

// Strapi Keys
console.log("\n=== STRAPI KEYS ===");
console.log("JWT_SECRET=", generateBase64Key(32));
console.log("ADMIN_JWT_SECRET=", generateBase64Key(32));

// Generate 4 APP_KEYS for Strapi
const appKeys = [];
for (let i = 0; i < 4; i++) {
  appKeys.push(generateBase64Key(32));
}
console.log("APP_KEYS=", appKeys.join(","));

console.log("\n✅ Keys generated successfully!");
console.log("\n📝 Copy these values to your respective .env files:");
console.log("   • docker/stack-auth/.env");
console.log("   • apps/strapi/.env");

console.log("\n🔒 Security tips:");
console.log("   • Never commit .env files to version control");
console.log("   • Use different keys for different environments");
console.log("   • Rotate keys regularly in production");
console.log(
  "   • Store production keys securely (e.g., in a password manager)",
);

function generateBase64Key(length) {
  return crypto.randomBytes(length).toString("base64");
}

function generateAlphanumeric(length) {
  const chars =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}
