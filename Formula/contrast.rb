
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.3.2/mac/contrast"
    sha256 "33b51bf544ea49e2b29ad998409686438c6b1d315a4ea0375dbeaea57889ea6b"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/2.3.2/linux/contrast"
      sha256 "e2d16fcc0c072e92b83ced31e23450696c1c0a4cb1e96772a5700044ce52ac49"
    end
  end

  def install
    bin.install "contrast"
  end
end

