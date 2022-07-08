
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.5/mac/contrast"
    sha256 "13ce903064b70ab68d381534e973730842cc0db64c2a2dec613b833fff820b94"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.5/linux/contrast"
      sha256 "5c1ec9ec926630ed2b201a8c02a0c136b8ee65bea909aaf69637167128a15cf8"
    end
  end

  def install
    bin.install "contrast"
  end
end

