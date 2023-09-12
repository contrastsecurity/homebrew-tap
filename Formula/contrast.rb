
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.2/mac/contrast"
    sha256 "63018bf30659d3ee3484ebacb7b42c7f04330589b7bde1f05d29e6ead209d51f"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.2/linux/contrast"
      sha256 "17a834ee76b9683fdf02a91615192d0b585411b43ff171a13b1caf1056ac66d8"
    end
  end

  def install
    bin.install "contrast"
  end
end

