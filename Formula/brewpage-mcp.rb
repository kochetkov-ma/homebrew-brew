require "io/wait"
require "json"

class BrewpageMcp < Formula
  desc "Publish pages, static sites, JSON and files through MCP"
  homepage "https://github.com/kochetkov-ma/brewpage-openapi/tree/main/mcp-server"
  url "https://github.com/kochetkov-ma/brewpage-openapi/archive/299984201a3d93264e20c7886e88dc6315909654.tar.gz"
  version "3.0.0"
  sha256 "8c803b6e1e3f4ad9e0c4cfa227a52344a62985f92ed505b4458bc962ddde7a92"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/brewpage-mcp/-/brewpage-mcp-3.0.0.tgz"
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
    # GIVEN the installed anonymous server WHEN a client connects THEN the compact catalog matches.
    env = {
      "BREWPAGE_URL"                => "http://127.0.0.1:1",
      "BREWPAGE_MCP_CATALOG"        => "compact",
      "BREWPAGE_MCP_TOOL_SELECTION" => nil,
    }
    IO.popen(env, [(bin/"brewpage-mcp").to_s, "--anonymous"], "r+") do |io|
      request = { jsonrpc: "2.0", id: 1, method: "initialize", params: {
        protocolVersion: "2025-11-25", capabilities: {}, clientInfo: { name: "homebrew-test", version: "1.0.0" }
      } }
      io.puts request.to_json
      io.flush
      assert_equal io, io.wait_readable(15), "MCP initialization must answer offline"
      response = JSON.parse(io.gets)
      assert_equal({ "name" => "brewpage-mcp", "version" => version.to_s },
                   response.dig("result", "serverInfo"), "Server identity must match")
      io.puts({ jsonrpc: "2.0", method: "notifications/initialized" }.to_json)
      io.puts({ jsonrpc: "2.0", id: 2, method: "tools/list", params: {} }.to_json)
      io.flush
      assert_equal io, io.wait_readable(15), "MCP tool discovery must answer offline"
      names = JSON.parse(io.gets).dig("result", "tools").map { |tool| tool.fetch("name") }.sort
      expected = %w[account delete_page_data delete_publication domains get_guide list_publications
                    notifications publication_settings publish read_page_data read_publication
                    update_publication write_page_data]
      assert_equal expected, names, "The thirteen compact tool names must match"
    end
  end
end
