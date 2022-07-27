
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.9/mac/contrast"
    sha256 "d06619cc30226224aa887e4e8c2901ee09f03b943ca8772b235efe91f4d366f3"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.9/linux/contrast"
      sha256 "8033ad36f7a9f45dda203fe2abdffdf33738336d9860d6ee6e332c274ed4176b"
    end
  end

  def install
    bin.install "contrast"
  end
end

