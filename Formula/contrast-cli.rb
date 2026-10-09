class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.1.0"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cns-darwin-arm64.tar.gz"
      sha256 "62906a7534511eb28dae93a3ab7452fd8175bac92f789bee73a9c2636c606255"
    end
    on_intel do
      url "#{base_url}/contrast-cns-darwin-amd64.tar.gz"
      sha256 "47c5ded108139cb8fd251cde78527b5f8c64bfe2d3472ada6e81f2cc5fff816b"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cns-linux-arm64.tar.gz"
      sha256 "a78aa98e971af82c397e1a260970df6e46fc462e2bc8de298a1b2cbb2ba69b26"
    end
    on_intel do
      url "#{base_url}/contrast-cns-linux-amd64.tar.gz"
      sha256 "d02e875e2117207bfe524ed26ce78643d16894ae575cb925cb18089bbbe827df"
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
