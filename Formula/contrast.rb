
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.22/mac/contrast"
    sha256 "83d17bfafad4d9d70a15557c16f1f7531cd6f16c602a622e993880628ca8a07a"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.22/linux/contrast"
      sha256 "6784752b931b990484fc7172c50a3493c74e60bb848018bd04872c8c372659b2"
    end
  end

  def install
    bin.install "contrast"
  end
end

