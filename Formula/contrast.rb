
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.3/mac/contrast"
    sha256 "fdd3b8d5c585114c6cae893d203b47640c6e8c107dd9c1d772abef96abab416f"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.3/linux/contrast"
      sha256 "a57940de0bbe21a90aa4f0510c87d10ac6a4971e0787b47140c92f67c1e70c7d"
    end
  end

  def install
    bin.install "contrast"
  end
end

