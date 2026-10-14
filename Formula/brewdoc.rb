# Source: 00b857115b1ec1cbe14d09f5c911842908a4dc30
require "json"

class Brewdoc < Formula
  desc "Deterministic document-to-Markdown conversion"
  homepage "https://github.com/kochetkov-ma/brewdoc"
  version "0.4.1"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sequoia
    preserve_rpath
    url "https://github.com/kochetkov-ma/brewdoc/releases/download/v0.4.1/brewdoc-0.4.1-macos-arm64.tar.gz"
    sha256 "f07f417114712a4d47e9e94d889818b8b367dcf503289ab9357970c85e227013"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://github.com/kochetkov-ma/brewdoc/releases/download/v0.4.1/brewdoc-0.4.1-linux-x64.tar.gz"
    sha256 "789915a7844f3a3b5d636bf79f3aed74062a7b0a051acb60558022528bf8f8f6"
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
    libexec.chmod 0755
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
