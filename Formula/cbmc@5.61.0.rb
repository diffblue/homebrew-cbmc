class CbmcAT5610 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.61.0",
      revision: "8f147113c34b06a03e1308b5ef4f5a496f76cd6a"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "377394c75753425e104ceb99bf8c53e558307ef891fb94eb6ba6723057933a19"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "f9e9cb04342e90c800015d63b28e5c7a856ed2f9ba7765707299b4f20e93ab88"
    sha256 cellar: :any_skip_relocation, monterey:       "72a8909ea45f296c537cab0f5369feb898df5bfc3a2668d3e22af2be301e2da7"
    sha256 cellar: :any_skip_relocation, big_sur:        "d10e75b2f0e0795761dcc9ad5d3760dbbb664eda7ca047666a600d831d96fc1f"
    sha256 cellar: :any_skip_relocation, catalina:       "4ba7a18f2b9eb5657ad3d33236a6b30051946b7d0f9bc642a97fac7a6c942fe4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8b69a0e4085ecad9efee7e84a8e7b1705d5c8a17892c9dc19662528b43f16918"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # lib contains only `jar` files
    libexec.install lib
  end

  test do
    # Find a pointer out of bounds error
    (testpath/"main.c").write <<~EOS
      #include <stdlib.h>
      int main() {
        char *ptr = malloc(10);
        char c = ptr[10];
      }
    EOS
    assert_match "VERIFICATION FAILED",
                 shell_output("#{bin}/cbmc --pointer-check main.c", 10)
  end
end
