class CbmcAT640 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.4.0",
      revision: "cbmc-4f56b6a911911fe89c73e2b6b58c96852e8b233d"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "1afe625f9beba019f9b615ca81430b4ade5a41d4c5d011217b8f63d50b50f198"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "a9f77303f241f6050ed86f3a6fb81a9ea3eb3595f5bfc70861961932f74d9f0a"
    sha256 cellar: :any_skip_relocation, sonoma:            "bfbf8341d5af86a3eb512d3c818e6c318c9a3e24f4e83a4d89f4ab68ae12163d"
    sha256 cellar: :any_skip_relocation, ventura:           "a6f2b900703c227d5d2e767eea7184f0a04abe2177864bae6441b9cd1ebced63"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "a28da9bf0494960e632b2cc6ebeac1b6760c2550dbebd5b2ef24b4516c913aaa"
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
