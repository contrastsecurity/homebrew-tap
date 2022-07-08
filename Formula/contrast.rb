
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.6/mac/contrast"
    sha256 "3c29f2e0b4c4ea589cbf9ac7776038de28fd98374f8eeb0e788d470e515b9d2e"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.6/linux/contrast"
      sha256 "02e705acdfe70f65a6598b9bd1164a48299944e07d851067cb31bc8b992bf1df"
    end
  end

  def install
    bin.install "contrast"
  end
end

