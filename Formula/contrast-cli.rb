class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.0.52"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cns-darwin-arm64.tar.gz"
      sha256 "8fca3362f2c8668c611925927a5e8edee0e744a43f14083df8bf591c036bb936"
    end
    on_intel do
      url "#{base_url}/contrast-cns-darwin-amd64.tar.gz"
      sha256 "a7f4f825400742069a387a146136ab35a0c0c00edfdb768c012838f428c59227"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cns-linux-arm64.tar.gz"
      sha256 "b6488f5ce2e261ee4091877f541a0568178d061a3ff3e872b3e848e42682dcd3"
    end
    on_intel do
      url "#{base_url}/contrast-cns-linux-amd64.tar.gz"
      sha256 "f54c8c48261c6a177da48a44539f4658b9a0c28b8b598cda92a887d3a3d6f54b"
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
