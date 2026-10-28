require "json"

class BrewpageMcp < Formula
  desc "Publish pages, static sites, JSON and files through MCP"
  homepage "https://github.com/kochetkov-ma/brewpage-openapi/tree/main/mcp-server"
  url "https://github.com/kochetkov-ma/brewpage-openapi/archive/57e1603b5f1101bd66204e64b9e0a13743e87672.tar.gz"
  version "1.15.1"
  sha256 "2834a6bd800e30c28212d9697266e74ea27f75ee5243317261d41b73dab06d0f"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/brewpage-mcp"
    strategy :npm
  end

  depends_on "node"

  def install
    cd "mcp-server" do
      system "npm", "ci", "--ignore-scripts", "--no-audit", "--no-fund"
      system "npm", "run", "build"
      system "npm", "prune", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund"
      libexec.install "dist", "node_modules", "package.json", "LICENSE", "README.md"
    end
    chmod 0755, libexec/"dist/index.js"
    (bin/"brewpage-mcp").write_env_script libexec/"dist/index.js", PATH: "#{formula_opt_bin("node")}:$PATH"
  end

  test do
    IO.popen([bin/"brewpage-mcp"], "r+") do |io|
      request = { jsonrpc: "2.0", id: 1, method: "initialize", params: {
        protocolVersion: "2025-11-25", capabilities: {}, clientInfo: { name: "homebrew-test", version: "1.0.0" }
      } }
      io.puts request.to_json
      io.flush
      assert_equal io, io.wait_readable(15), "MCP initialization must answer offline"
      response = JSON.parse(io.gets)
      assert_equal "brewpage-mcp", response.dig("result", "serverInfo", "name"), "Server identity must match"
      assert_equal version.to_s, response.dig("result", "serverInfo", "version"), "Server version must match"
      io.puts({ jsonrpc: "2.0", method: "notifications/initialized" }.to_json)
      io.puts({ jsonrpc: "2.0", id: 2, method: "tools/list", params: {} }.to_json)
      io.flush
      assert_equal io, io.wait_readable(15), "MCP tool discovery must answer offline"
      names = JSON.parse(io.gets).dig("result", "tools").map { |tool| tool.fetch("name") }.sort
      assert_equal 20, names.length, "All twenty tool schemas must be available"
      assert_includes names, "publish_site", "Site publishing schema must be present"
    end
  end
end
