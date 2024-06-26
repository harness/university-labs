/** @type {import('next').NextConfig} */
const nextConfig = {}
var os = require("os");
var hostname = os.hostname();

module.exports = nextConfig

// next.config.js
module.exports = {
    // ... rest of the configuration.
    env: {
      HOSTNAME: hostname,
      UMS_URL: process.env.UMS_URL,
      NEXT_PUBLIC_BUILD_VERSION: "7.0.0",
      NEXT_PUBLIC_ACTIVE_PROFILE: "dev"
    },
    output: 'standalone',
  }