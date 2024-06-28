
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.2.0/mac/contrast"
    sha256 "2a8fc1eba67083e2d0631d6dc02828025b74b3e41cf5d391502eec6420d53187"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.2.0/linux/contrast"
      sha256 "4121977fc5e040ac472030e5105d2ceb5039a411711a7a2bf9c8456ef2c7d04f"
    end
  end

  def install
    bin.install "contrast"
  end
end

