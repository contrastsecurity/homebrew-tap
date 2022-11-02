
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.19/mac/contrast"
    sha256 "7b46e27ba3b74bb5aa2b7fc1c9bd1b7d1b906a53ae1cf975f442f030a8c72ded"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.19/linux/contrast"
      sha256 "3e8a4c7e591c3defa816dc2e4d7abecefe629d7cf6141feb83414b105ae4c01d"
    end
  end

  def install
    bin.install "contrast"
  end
end

