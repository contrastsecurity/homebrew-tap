
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.10/mac/contrast"
    sha256 "2611e92362019441a62b6e441eb041280b7a455f3414ab9dcfb3eec9f3b2bf4d"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.10/linux/contrast"
      sha256 "0920b7b4f7960d7912cf324d9a320e594912deac7cc323290600864573375266"
    end
  end

  def install
    bin.install "contrast"
  end
end

