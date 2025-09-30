
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.4/mac/contrast"
    sha256 "d9b0e03e70f3bbc57a85055c595ef181abc3ca3bd3d815704c95e571e0e3468c"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.4/linux/contrast"
      sha256 "6c3184fc722c7d114665554febdcc787ee3d7eae82908e840dbe50637e271dd0"
    end
  end

  def install
    bin.install "contrast"
  end
end

