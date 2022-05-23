
class Contrast < Formula
    desc "Contrast CLI"
    homepage "https://github.com/contrastsecurity/contrast"
    license "MIT"

    if OS.mac?
      url "https://contrastsecurity.jfrog.io/artifactory/cli/1.0.1/mac/contrast"
      sha256 "a23362b7abcf1af058a5292fe4a5c6ee33aed34249b4ff4074b84f7d129777c6"

    elsif OS.linux?
      if Hardware::CPU.intel?
        url "https://contrastsecurity.jfrog.io/artifactory/cli/1.0.1/linux/contrast"
        sha256 "ec252ce54e002062e4e43377db4b066c51bb5f6f124680ac93eda0cf3a34bf63"
      end
    end

    def install
      bin.install "contrast"
    end
  end

