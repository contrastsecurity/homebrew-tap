
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/1.0.2/mac/contrast"
    sha256 "439342259de454f06bc8312b5ccd1cf51251b5ccb915dd31ab0970597de84a3f"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/1.0.2/linux/contrast"
      sha256 "5895d3ab1a6b838f3cd4107fa8e5aa067cbc7551d82de152d10e1b619e01b8f5"
    end
  end

  def install
    bin.install "contrast"
  end
end

