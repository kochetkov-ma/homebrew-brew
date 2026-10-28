# Brew tools Homebrew tap

## BrewPage MCP

Install the MCP server for publishing and managing pages, built static sites, JSON, files and key-value stores:

```sh
brew install kochetkov-ma/brew/brewpage-mcp
```

Configure your MCP client to run `brewpage-mcp` with stdio transport. The formula builds version 1.15.1 from its checksummed source revision and locked npm dependencies. Its offline test initializes the protocol and discovers tool schemas without publishing content.

The MCP client is MIT; the hosted BrewPage service is proprietary. Publications expire. See [the server documentation](https://github.com/kochetkov-ma/brewpage-openapi/tree/main/mcp-server).

## Brewdoc

This tap installs the complete Brewdoc native bundle on macOS ARM64 and Linux x64/glibc.
Use the channels listed as available in the [Brewdoc release](https://github.com/kochetkov-ma/brewdoc/releases).
See [installation instructions](https://github.com/kochetkov-ma/brewdoc/blob/main/INSTALL.md) for supported platforms and lifecycle commands.
