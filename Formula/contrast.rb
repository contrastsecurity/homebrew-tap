
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.1.0/mac/contrast"
    sha256 "2cf7ea597296e6b1320e14962dff58d8a0d85d8cfe56c2210a74839343c9dfd0"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.1.0/linux/contrast"
      sha256 "26d088f2e4de629c4b4009232c757b79b45326b99d6ff14ff6e31565df5d4517"
    end
  end

  def install
    bin.install "contrast"
  end
end

