class CbmcAT5770 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.77.0",
      revision: "e1e7dc7426168bca56ee92bf1513053c7db99317"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "185c3bd4749c46f35311d02d7f717ea6ea40187813628d59e1d241aac8745b28"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "7007d2536628ad9dd797e3f3b1c02fcb8a560470ad6db7332d21869276eac821"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "820cddab495928c85b9a10358070c610c9cdd39621a8cea4300ee945b766c775"
    sha256 cellar: :any_skip_relocation, ventura:        "b983c686a341792a9d589e619080db64cb85c1a2b00eed68d097e610c6fe901c"
    sha256 cellar: :any_skip_relocation, monterey:       "b0862a7921778b44fb1452a445683bb23ba077c73242249eff7910d992a0ed2f"
    sha256 cellar: :any_skip_relocation, big_sur:        "233f49775618acb48e692f36a02a02e4de52d0bf088e062a2591c933434e8882"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "792efad28d94e13612ef08c30a36e25369f306f68f7055d71f1cc8fdc9d26abf"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build
  depends_on "rust" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

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
