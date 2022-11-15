
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.20/mac/contrast"
    sha256 "911ae77717d808ef573866e92dbd1c8dfd3e2f50b06720f26745f68278240435"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.20/linux/contrast"
      sha256 "01ce07452a09856e641e4fedb86692aa843c32a4590900a0b0b4fc82e3360b75"
    end
  end

  def install
    bin.install "contrast"
  end
end

