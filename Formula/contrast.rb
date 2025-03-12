
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.0/mac/contrast"
    sha256 "723d7214472e659b31e13d3389da5abc5c862f875ad5b1f77b9c8ad3070f5cd5"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.0/linux/contrast"
      sha256 "4b57faf952f90399adff0137c8f2281611217f73ee861a6a0ad317eb51ab8a77"
    end
  end

  def install
    bin.install "contrast"
  end
end

