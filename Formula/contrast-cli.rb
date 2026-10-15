class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.1.2"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cli-darwin-arm64.tar.gz"
      sha256 "9d8be56c9f217efb2fa50c152fc08091ba2652434516b181489a7b0301d2ddaf"
    end
    on_intel do
      url "#{base_url}/contrast-cli-darwin-amd64.tar.gz"
      sha256 "ff3baef132509481e8627edde09e4e836e43dd5b113bfa3c6df5947555f13413"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cli-linux-arm64.tar.gz"
      sha256 "d14a7d61db7d50bf682c50412b04ee8131680b44313357bcb991a498cead4474"
    end
    on_intel do
      url "#{base_url}/contrast-cli-linux-amd64.tar.gz"
      sha256 "a58e244a08e0ca5b6b59db694096b4b17fed611823f19128c4efbb8d483ec93e"
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
