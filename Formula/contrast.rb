
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.16/mac/contrast"
    sha256 "abc3f22f3e5b4d338358190894e722ca86fd24f63e2a549c817e2f747e557a2b"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.16/linux/contrast"
      sha256 "936d2f0e2a54164fc9a9ebbaf3aa85a69091e9d5c1214e6c6e62f001b84bc442"
    end
  end

  def install
    bin.install "contrast"
  end
end

