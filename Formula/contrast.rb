
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.4.0/mac/contrast"
    sha256 "48593d2c6894fd95ad1b8ac63e2a3eb6c7f40dd5177e75da3e8a6de4ce34ea64"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.4.0/linux/contrast"
      sha256 "e00137a308afdd8b2a53f960ea2c2e2fad174791b763a43ff46489e869ffc1c5"
    end
  end

  def install
    bin.install "contrast"
  end
end

