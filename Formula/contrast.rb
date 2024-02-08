
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.6/mac/contrast"
    sha256 "ce30e11036b8155fd5f306986ec6bad65394d449a661962da177e77a2c4aeceb"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.6/linux/contrast"
      sha256 "9af993f8d104cc43887516496a639d53f249932450362300e27310e7a42c1ad6"
    end
  end

  def install
    bin.install "contrast"
  end
end

