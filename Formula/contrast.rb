
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.0.0/mac/contrast"
    sha256 "f04d80422b3f2e72c63b8f8a7948e400b16e24e0091a68cb8842031f7490eab1"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.0.0/linux/contrast"
      sha256 "3d0597f1531d71a9b39b293c0875454eb05effa9514062ccf7c2546f2033d0db"
    end
  end

  def install
    bin.install "contrast"
  end
end

