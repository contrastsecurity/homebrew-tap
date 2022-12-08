
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.21/mac/contrast"
    sha256 "8e29362e4d8e998763479561d08c727a43d366cb62e9200454683ff52cdf02d0"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.21/linux/contrast"
      sha256 "27e12342b796dd3452e1c30cbbeb6b5b142b6b31dc3cda38c7e1976d9c0231dc"
    end
  end

  def install
    bin.install "contrast"
  end
end

