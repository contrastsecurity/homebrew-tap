class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.0.60"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cns/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cns-darwin-arm64.tar.gz"
      sha256 "20ae266adeba7f5fe61679c2f2deb66247b072203fa3236ca7f1839728d17730"
    end
    on_intel do
      url "#{base_url}/contrast-cns-darwin-amd64.tar.gz"
      sha256 "980853d895fbebc1d908a98de3ff8e9ecb5b699af270218e249b9f8f2492611b"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cns-linux-arm64.tar.gz"
      sha256 "ebdbf249066b17596f7395048a2ce949ada11f2d09a91d8fef39fc324ceddc59"
    end
    on_intel do
      url "#{base_url}/contrast-cns-linux-amd64.tar.gz"
      sha256 "0572f53f669234e06da78c542a497beb27b0d9a3120a63df3e37c40bab1316a9"
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
