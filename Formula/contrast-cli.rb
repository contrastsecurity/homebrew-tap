class ContrastCli < Formula
  desc "Contrast CNS CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.0.47"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cns-darwin-arm64.tar.gz"
      sha256 "80f6949df97df3b1f6dc02bc746aed62238570a25d319736f0f166bfe48f9fc4"
    end
    on_intel do
      url "#{base_url}/contrast-cns-darwin-amd64.tar.gz"
      sha256 "e5a28bdebb803b2e11b7c5d0b64ac214feb2433f216d22397e782c70af35604b"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cns-linux-arm64.tar.gz"
      sha256 "c84c3edf616bd1d911c6a7229b6ba9731d7efa553c78b9e9ca8eceab6f7bd86f"
    end
    on_intel do
      url "#{base_url}/contrast-cns-linux-amd64.tar.gz"
      sha256 "54c2f8bbc0b0c88cc6c4366fa5f65ba8f14aca578557c7e318cd163ad0623b33"
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
