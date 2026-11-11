require "json"

class BrewpageMcp < Formula
  desc "Publish pages, static sites, JSON and files through MCP"
  homepage "https://github.com/kochetkov-ma/brewpage-openapi/tree/main/mcp-server"
  url "https://github.com/kochetkov-ma/brewpage-openapi/archive/2969cbcb0e9756e84864d26436c1dbcc22674ef6.tar.gz"
  version "1.19.0"
  sha256 "3cc362e9417fb091d601c52f0930fea7c94d217fda0d06f7712e72232c814632"
  license "MIT"

  livecheck do
    url "https://registry.npmjs.org/brewpage-mcp/-/brewpage-mcp-1.19.0.tgz"
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
    # GIVEN installed stdio executable; WHEN initialized; THEN identity and offline tools match.
    IO.popen([bin/"brewpage-mcp"], "r+") do |io|
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
      expected = %w[bind_token check_domain configure_page_data delete_page_data delete_resource get_guide
                    get_json get_kv get_limits get_page get_page_data get_stats list_domains mint_token
                    publish_file publish_html publish_json publish_kv publish_site remove_domain
                    republish_site search_gallery set_domain set_kv set_page_data set_title set_visibility
                    update_hosting update_html update_json]
      assert_equal expected, names, "All thirty tool schemas must match"
    end
  end
end
