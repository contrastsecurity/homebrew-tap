
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.15/mac/contrast"
    sha256 "a6fbd505f802c27f3d73ec76ee25433eea5b585a0e1c51daeff1c83bb46cbdb6"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.15/linux/contrast"
      sha256 "0eeb41e9ce5e0766c98c4b481c28344205c6979a4d9965cc8cbdf1da3e124ab5"
    end
  end

  def install
    bin.install "contrast"
  end
end

