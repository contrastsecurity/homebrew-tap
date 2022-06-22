
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.4/mac/contrast"
    sha256 "ef0a4e516ae41360432bd0776e4b5298fe47bdcae34cdb465c05aa5f66ee2cd3"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.4/linux/contrast"
      sha256 "cf67db2ca987e77fcc966331d84acb05e52d130e736d61e61a5f75e3addc97ae"
    end
  end

  def install
    bin.install "contrast"
  end
end

