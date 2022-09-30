
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.14/mac/contrast"
    sha256 "c4ad1cd737fe854c91d77e280e91ca253a57282bc91557e75c80f26a19951c74"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.14/linux/contrast"
      sha256 "554fce4bb0f1b010dc989fda1af2e754c2ff737883bf214f9d2b19ea4ec3df55"
    end
  end

  def install
    bin.install "contrast"
  end
end

