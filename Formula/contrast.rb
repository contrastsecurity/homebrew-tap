
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.18/mac/contrast"
    sha256 "815e596c9cfbb662f1d9cfb24e497d3bc1093b4c6f39c5f80e7ec489e192058a"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.18/linux/contrast"
      sha256 "9af0613be7e33a8a7b588723d1f82aec603326dc36cf146c2d4bf02a2ce76068"
    end
  end

  def install
    bin.install "contrast"
  end
end

