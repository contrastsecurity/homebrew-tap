
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.23/mac/contrast"
    sha256 "afe0bf8740d974974406af3f80d811d893b181b1bd8f81ae2774f79bc3c01040"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://pkg.contrastsecurity.com/artifactory/cli/1.0.23/linux/contrast"
      sha256 "5111af91ad196831f5643552261235b43d48f13bfd8606161ec9c450f9697d80"
    end
  end

  def install
    bin.install "contrast"
  end
end

