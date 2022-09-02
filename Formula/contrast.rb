
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.12/mac/contrast"
    sha256 "295e88efae328ddf1f33880b51d5dc2962e65a353af9a9358e53fa6813db1e8f"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.12/linux/contrast"
      sha256 "3f8206cc7f6a20e1cde28aa923df2133474aaf5672d4a68a665c379c2921db58"
    end
  end

  def install
    bin.install "contrast"
  end
end

