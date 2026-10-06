
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.7/mac/contrast"
    sha256 "2340c5351454e23326a40cf2d854d2cf4be946ff2074aa2490b11d8d74997806"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.7/linux/contrast"
      sha256 "64ed7ea0829ed5a017dcbd9f49bde20bee1ecc4cb543d1bba8b2aa5c7250a273"
    end
  end

  def install
    bin.install "contrast"
  end
end