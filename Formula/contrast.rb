
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.0/mac/contrast"
    sha256 "e587c49f403bc57a31c56ebed02676d416ab0b4dd8969454b51934691f7915f3"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.0/linux/contrast"
      sha256 "cd4ed04eb4e38666413ee06acdf365b0e0f43a32e139643af045fa982a20f1d3"
    end
  end

  def install
    bin.install "contrast"
  end
end

