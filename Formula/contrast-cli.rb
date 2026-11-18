class ContrastCli < Formula
  desc "Contrast CLI"
  homepage "https://www.contrastsecurity.com"
  version "0.2.2"

  base_url = "https://pkg.contrastsecurity.com/artifactory/pathfinder-beta-distro/contrast-cli/#{version}"

  on_macos do
    on_arm do
      url "#{base_url}/contrast-cli-darwin-arm64.tar.gz"
      sha256 "d5c8b0d88161287ebba2a12f07b93216521e4893ce7827b97e9b045d91a31212"
    end
    on_intel do
      url "#{base_url}/contrast-cli-darwin-amd64.tar.gz"
      sha256 "0f328649eece32663cf8a0d495e37f464168d743b433947baded67db6a7c7d33"
    end
  end

  on_linux do
    on_arm do
      url "#{base_url}/contrast-cli-linux-arm64.tar.gz"
      sha256 "299e16c3457a7e77be4f7a0856d39489e289a1cf93a174ff7131c94d67433e12"
    end
    on_intel do
      url "#{base_url}/contrast-cli-linux-amd64.tar.gz"
      sha256 "faf9e6c2ac6b8521950639033778da4da3f2aa2640efcf184a297407ac0880ae"
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
