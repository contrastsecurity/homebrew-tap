class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.2.1"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cli-darwin-arm64.tar.gz"
      sha256 "2eda64afed56dd74920e17094a24bc68bb5c439c385ccdb97dd44da0a531488d"
    end
    on_intel do
      url "#{base_url}/contrast-cli-darwin-amd64.tar.gz"
      sha256 "edfb1b13909af61b3b829c265cfcac77d2dc39206d28ae54b757258e5557d081"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cli-linux-arm64.tar.gz"
      sha256 "0b3638ac27a204ee8f2eefe188de2cb10598e9222682c97ded79008e72746701"
    end
    on_intel do
      url "#{base_url}/contrast-cli-linux-amd64.tar.gz"
      sha256 "20521bb8b2f325a1eb03eb1f4c5f7a6b65985485288aaef6c84406f04e8b2764"
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
