class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.2.0"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cli-darwin-arm64.tar.gz"
      sha256 "49a2f2b9cbc678454a31a931eac1f67ddcbeff91d83638917c4cbc2b6002e49d"
    end
    on_intel do
      url "#{base_url}/contrast-cli-darwin-amd64.tar.gz"
      sha256 "9741a09ea46e6e9bf76e588803895509dd1c9831dc0399d916c924c847796d2e"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cli-linux-arm64.tar.gz"
      sha256 "5731d9410eac6bbd3b482478ff76bed553caa4671d86591935625a9c6e98af68"
    end
    on_intel do
      url "#{base_url}/contrast-cli-linux-amd64.tar.gz"
      sha256 "edd70977fa05f106770d883432319148de09e0c27560655133ff2532ec05532b"
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
