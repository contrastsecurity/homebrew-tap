
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.2/mac/contrast"
    sha256 "e0f992cd9028640686100d14fc3451224ec4255866bcb10d2dfce639c0cd3642"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.2/linux/contrast"
      sha256 "6c3740a6ea1b02279da2b36366cd1077e3af5c329c849e3e61231326d2aabae0"
    end
  end

  def install
    bin.install "contrast"
  end
end

