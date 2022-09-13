
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.13/mac/contrast"
    sha256 "59c67981b8735736848643612b94dc48d0cd7ecd7721fc4f457a320498fc30e1"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.13/linux/contrast"
      sha256 "866a05de45734e82ae7756d66fa89fbcc317664fea1fa80dd338645ea5dc4363"
    end
  end

  def install
    bin.install "contrast"
  end
end

