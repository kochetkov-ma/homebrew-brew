# Source: 1471975a6fbd8a17766278fd5a0738c095f2ec57
require "json"

class Brewdoc < Formula
  desc "Deterministic document-to-Markdown conversion"
  homepage "https://github.com/kochetkov-ma/brewdoc"
  version "0.5.0"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sequoia
    preserve_rpath
    url "https://github.com/kochetkov-ma/brewdoc/releases/download/v0.5.0/brewdoc-0.5.0-macos-arm64.tar.gz"
    sha256 "4ad6b07de2af9a89912a6682c133528a49fab5eb72c5c2dca98d8e099abc9aaf"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/kochetkov-ma/brewdoc/releases/download/v0.5.0/brewdoc-0.5.0-linux-x64.tar.gz"
    sha256 "ac10ed1b359491635ed6d265eb0305124b5c5107bdaef2a42687ac7f1b83ce17"
  end

  skip_clean "libexec"

  def install
    supported = (OS.mac? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?) ||
                (OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?)
    odie "Brewdoc supports macOS ARM64 and Linux x64" unless supported
    odie "Brewdoc requires macOS 15 or newer" if OS.mac? && MacOS.version < :sequoia
    if OS.linux?
      glibc = Utils.safe_popen_read("/usr/bin/getconf", "GNU_LIBC_VERSION").strip
      parsed = /\Aglibc (\d+)\.(\d+)\z/.match(glibc)
      odie "Brewdoc requires system glibc 2.35 or newer" unless parsed && (parsed.captures.map(&:to_i) <=> [2, 35]) >= 0
    end
    unless File.executable?("brewdoc") && File.directory?("_internal") &&
           File.directory?("licenses") && File.file?("version.json")
      odie "Unexpected Brewdoc archive layout"
    end
    libexec.install Dir.children(".") - [".brew_home"]
    bin.install_symlink libexec/"brewdoc"
  end

  test do
    assert_match "self-check: ok", shell_output("#{bin}/brewdoc --self-check")
    (testpath/"probe.html").write("<html><body><p>Homebrew probe</p></body></html>")
    output = shell_output("#{bin}/brewdoc #{testpath}/probe.html")
    receipt, markdown = output.split("\n", 2)
    status = JSON.parse(receipt)
    assert_equal true, status.fetch("file_ok"), "The offline HTML probe must render"
    assert_equal "html", status.fetch("route"), "The local input must use the HTML route"
    assert_match "\nHomebrew probe\n", markdown
  end
end
