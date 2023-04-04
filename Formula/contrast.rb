
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.24/mac/contrast"
    sha256 "017962d46f1edcd4ce5f1d2a090a51b1dff0cd8d7e379ac467c6ca0700131549"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.24/linux/contrast"
      sha256 "772b6361f17f2532a6314c4db26770104a2a6378525e89524e4903c7efe6f914"
    end
  end

  def install
    bin.install "contrast"
  end
end

