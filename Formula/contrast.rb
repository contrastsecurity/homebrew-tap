
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.3.1/mac/contrast"
    sha256 "0acbf08b404d0a859d9d2bb65083e625b32c8f0090d459a8e60d8f7cb2c6ffca"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.3.1/linux/contrast"
      sha256 "5efe5456427fd2f5a2e9ab389ae2e9505f6f324b51db1264cf92337175ad3721"
    end
  end

  def install
    bin.install "contrast"
  end
end

