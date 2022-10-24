
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.17/mac/contrast"
    sha256 "97a151a548d465d943a2d8b408ccf9ecf5a4e19094d3e0a5b822ed03cc98a5ad"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.17/linux/contrast"
      sha256 "8b02fecbfd474f575bba2391fa41a25339883996fdaa00b1d5874a9acae644b8"
    end
  end

  def install
    bin.install "contrast"
  end
end

