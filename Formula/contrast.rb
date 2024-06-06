
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.7/mac/contrast"
    sha256 "2711cbceab77d3598f87d6ab870a19827dcfc720016f7e087153af35c0b0bb5e"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/v2/2.1.7/linux/contrast"
      sha256 "b7f85702141c5d1ba64e2569d147de326cda63c4208b8d3182da49d649febb6e"
    end
  end

  def install
    bin.install "contrast"
  end
end

