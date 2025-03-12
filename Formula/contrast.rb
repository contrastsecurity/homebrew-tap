
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.1/mac/contrast"
    sha256 "44681cd31460cc4943263766cba794350afef451d629288c7cf7883314fe6b05"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.5.1/linux/contrast"
      sha256 "9e717e009f079dfed0ae5aed40f88a0ae2554fc9907069c48c991508b85f7f97"
    end
  end

  def install
    bin.install "contrast"
  end
end

