class CbmcAT5780 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.78.0",
      revision: "a8abbf157233e33347dee68e6e3bfee1e385d208"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "6bccfab199bdaf61d3f0a3228ab2e908c483f51b1e783cc003b3281dd90a39ca"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "bad3385ed2ad08b59eb0183bc70943d00b78eb208107bc940a90918dbcd83c63"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "7ba46d92362ef139793a2e103b32cd1702bb16b92e68926d9f048a581cbcd8d7"
    sha256 cellar: :any_skip_relocation, ventura:        "10b840d2abde48d8179dc927dd2c50351b6bd2defed05523cdc5be4c92776775"
    sha256 cellar: :any_skip_relocation, monterey:       "a6cbf282d608ef77a92ea58f34bb0257b76e14b3a8aaf49461f087967cc83f7d"
    sha256 cellar: :any_skip_relocation, big_sur:        "00ad3dacb4d14f26256efd90a3f96062cf8dd60b748b3106518240eff496ddfb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "813918766be49b7985dffc80a65d626ac3ffdde7934d81c5bd16b5f25f7b9c9f"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build
  depends_on "rust" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  fails_with gcc: "5"

  def install
    system "cmake", "-S", ".", "-B", "build", "-Dsat_impl=minisat2;cadical", *std_cmake_args
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
