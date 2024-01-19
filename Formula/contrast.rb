
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.5/mac/contrast"
    sha256 "d52be7f86b14b088df5fd189ef0be2049f9eff4f25a9f8e13c2686be6310257e"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.5/linux/contrast"
      sha256 "16a341f0f12a9cebca381b57b4841cc5713ddceea4f3fee70f55c3ccfd66a66f"
    end
  end

  def install
    bin.install "contrast"
  end
end

