
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.1/mac/contrast"
    sha256 "10bcde9f7719230d1dd15ae2d199e59b383b7e3a3aedbd2eee312e4833cccc73"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.1/linux/contrast"
      sha256 "9b6e3d9471b82253a6b8dfedfcdd342160d636c7257a7fb7f3ea265d1b416b83"
    end
  end

  def install
    bin.install "contrast"
  end
end

