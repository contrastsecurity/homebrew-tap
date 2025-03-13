
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.2/mac/contrast"
    sha256 "71e030aa97c69caeebad65f48cf20e9939e70370f7fa9b25a096831388bfb891"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.2/linux/contrast"
      sha256 "392e1ea9e277723c8eee97c0474d73ed22ce288b1b8c01b5dcd45ad43da96cf2"
    end
  end

  def install
    bin.install "contrast"
  end
end

