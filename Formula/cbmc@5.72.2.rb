class CbmcAT5722 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.72.2",
      revision: "dcf0287060e133b7bc1a3a9f3287ec1dbd7837ef"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "c5f38ac6f64a065c962358926cebf162bf176a366d644ea14c1e05ddb2762184"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4634234bd40e2b70fbb39c368569bbb18c10ca9ad2695b4512862c021ab34f5f"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "7547ec6d036aff7bfff51c9f739757a2872cb734395912dda49d2beae6e91e46"
    sha256 cellar: :any_skip_relocation, ventura:        "5c1e8fd0bff1e0632367c295bd4ebe80fe222242f3bafa31b4f1cf8b310c6dc2"
    sha256 cellar: :any_skip_relocation, monterey:       "cd58b325a241e30a67e19f14b6ae1238f48cd2c113333721282478173d1902ce"
    sha256 cellar: :any_skip_relocation, big_sur:        "7c3b32fa1ceb7d7d94ea2c2ca3bb4ceb7ce73f9f537e8cbf6d443e8e12bc48cc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d37f391029fb17067c0c3a88b621d8aef0ad75555cefbac94bc8cd21e532ea2f"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build

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
