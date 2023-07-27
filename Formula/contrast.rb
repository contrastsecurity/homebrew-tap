
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.0/mac/contrast"
    sha256 "b7f175d240fbaa7866b58db90557da050ba895e04084a260f8b28b9b010903d9"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.0/linux/contrast"
      sha256 "51c7581269a964488e4bc8200f843d8b83341f10d80860936bca42baa91b67a4"
    end
  end

  def install
    bin.install "contrast"
  end
end

