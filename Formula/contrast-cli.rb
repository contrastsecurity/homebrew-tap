class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.1.1"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cli-darwin-arm64.tar.gz"
      sha256 "8247d38279eb0a70db331403446291c06f1c96b1e1cdfe12388c428ff374baf8"
    end
    on_intel do
      url "#{base_url}/contrast-cli-darwin-amd64.tar.gz"
      sha256 "099f4a2bc56358a38a3669d0d2b54f908ceec3fc87f12e4c7bf26a85e60a6ac2"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cli-linux-arm64.tar.gz"
      sha256 "888718159ae3ff0e132acbdb342a722f2faa1caa4518c13d08ff4c7a7d5b18a8"
    end
    on_intel do
      url "#{base_url}/contrast-cli-linux-amd64.tar.gz"
      sha256 "9d8dce73673ef930a72810b5189a766b89ab4c56004a8ee56294799fc2add596"
    end
  end

  def install
    # PyInstaller bundle: the executable loads its runtime from the sibling _internal directory
    libexec.install "contrast-cli", "_internal"
    bin.install_symlink libexec/"contrast-cli"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/contrast-cli --help")
  end
end
