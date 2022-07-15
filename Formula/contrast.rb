
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.7/mac/contrast"
    sha256 "014b9e9214caabfd916be521f794e4e9949e44afdb05c6254604613317bba801"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.7/linux/contrast"
      sha256 "0bad2be17072437a4a1be3084e3cc2cf3d0ab989dd4eee1592717c16e4e2860c"
    end
  end

  def install
    bin.install "contrast"
  end
end

