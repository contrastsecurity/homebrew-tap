
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.8/mac/contrast"
    sha256 "c5d9169500504da78072c3ca8b5af851dd53b3d5425101b44f6aaf3bf08a5223"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.8/linux/contrast"
      sha256 "0d73986d0a279c7b5d46c3313f6618056b89387906c947dabef49720f0109f78"
    end
  end

  def install
    bin.install "contrast"
  end
end

