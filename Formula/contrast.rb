
class Contrast < Formula
  desc "Contrast CLI"
  homepage "https://github.com/contrastsecurity/contrast"
  license "MIT"

  if OS.mac?
    url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.6/mac/contrast"
    sha256 "99588fc1b808d899c4741ea6663f6ca8762f24b0ec3d01f5f65fc2b58f860ecf"

  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/v2/3.2.6/linux/contrast"
      sha256 "9bfcd8d156f723553b704c5126233305ba8095da8eb49f8e6c10158994177895"
    end
  end

  def install
    bin.install "contrast"
  end
end

∑