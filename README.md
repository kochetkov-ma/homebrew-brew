# Brew tools Homebrew tap

## BrewPage MCP

Install the MCP server for publishing and managing pages, built static sites, JSON, files and key-value stores:

```sh
brew install kochetkov-ma/brew/brewpage-mcp
```

Configure your MCP client to run `brewpage-mcp` with stdio transport. The 3.0.1 formula builds from a checksummed source commit and locked npm dependencies.

```sh
brew test kochetkov-ma/brew/brewpage-mcp
```

The offline test starts `brewpage-mcp --anonymous` and checks the 13 compact tool names. Cached calls to older tool names still work. Set `BREWPAGE_MCP_CATALOG=legacy` in the client environment to list the previous catalog. On macOS, `brewpage-mcp login` connects a BrewPage account on a compatible deployment. Restart the client to use the connection. Run `brewpage-mcp logout` to revoke the selected grant.

The MCP client is MIT; the hosted BrewPage service is proprietary. Publications expire. See [the server documentation](https://github.com/kochetkov-ma/brewpage-openapi/tree/main/mcp-server).

## BrewPage CLI

Install the `brewpage` command to publish a file or stdin to brewpage.app and get one share link:

```sh
brew install kochetkov-ma/brew/brewpage
echo '# Hello' | brewpage -
```

Stdout carries only the link. The private management link and owner token go to a receipts file readable only by you. Publications are unlisted unless you pass `--public`, and expire (`--ttl N` sets the days). `brew test kochetkov-ma/brew/brewpage` runs offline. The CLI is Apache-2.0; the hosted BrewPage service is proprietary. See [the CLI README](https://github.com/kochetkov-ma/brewpage-cli#readme).

## Brewdoc

This tap installs the complete Brewdoc native bundle on macOS ARM64 and Linux x64/glibc.
Use the channels listed as available in the [Brewdoc release](https://github.com/kochetkov-ma/brewdoc/releases).
See [installation instructions](https://github.com/kochetkov-ma/brewdoc/blob/main/INSTALL.md) for supported platforms and lifecycle commands.
