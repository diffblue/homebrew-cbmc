class CbmcAT5860 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.86.0",
      revision: "892c792b43025feac551a95223b30f06b2c6a6dc"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "82760ea75223784bc0232bbbf2a49fdb71a9a4a6523afd1fd46cda8bf626f113"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0569e321e3837c53181124452ad6b898fbd9a60a140e878dfbbb10a8726c69b1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "00eb72e6e457b4d98b909aa826716fd1d8b5c75e232d1ccf2f61a43a825bdc27"
    sha256 cellar: :any_skip_relocation, ventura:        "fb7d440be16a164d2ab6f663cd71302b3fa17e412acfd0e204db58995c2a2d40"
    sha256 cellar: :any_skip_relocation, monterey:       "27b002d3458fb7b1fdcc8cbceca6e1fde6ba00b586a1792613504ec292349735"
    sha256 cellar: :any_skip_relocation, big_sur:        "a790e8dd8799297431ccf8a63de5c2d3da160fddd74ea1a3c23746dad34838c9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "58154406d558bd6e5b4648d279778763d801906064a20c09b220ba0ec9567b03"
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
