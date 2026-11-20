class Brewpage < Formula
  desc "Publish a file or stdin to brewpage.app and print the share link"
  homepage "https://github.com/kochetkov-ma/brewpage-cli"
  url "https://github.com/kochetkov-ma/brewpage-cli/releases/download/v0.1.0/brewpage-0.1.0.tgz"
  sha256 "dffc5e44fa2cfab63156c64d1a1fb9d31954f258895c938a897fe9df666a8888"
  license "Apache-2.0"

  depends_on "node"

  def install
    libexec.install Dir["*"]
    chmod 0755, libexec/"bin/brewpage.js"
    (bin/"brewpage").write_env_script libexec/"bin/brewpage.js", PATH: "#{formula_opt_bin("node")}:$PATH"
  end

  test do
    # GIVEN the installed CLI offline WHEN run THEN version, help and the network-failure exit code match.
    assert_equal "brewpage #{version}\n", shell_output("#{bin}/brewpage --version"), "Version line must match"
    assert_match "https://brewpage.app/help", shell_output("#{bin}/brewpage --help"), "Help must link the help page"
    ENV["BREWPAGE_URL"] = "http://127.0.0.1:#{free_port}"
    ENV["BREWPAGE_STATE_DIR"] = testpath.to_s
    assert_empty pipe_output("#{bin}/brewpage -", "# Homebrew probe\n", 5), "A failed publish must print no link"
  end
end
