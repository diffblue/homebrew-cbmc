class CbmcAT5820 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.82.0",
      revision: "1d0ee456728d747001dbb9f9098d9255adaf9d28"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "7b977590dc8c68a4f5ab4e59378888bde611f85fb00bc1a2c537ff226267feb0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "9a8028b9d1b55cbb775c4fb885f8dfa6cf79ca323ac3e689bc997b06790e971a"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "79565e868b60b38f0b32fe3ed877aca1d181177ab73576959ba98c9960933e4e"
    sha256 cellar: :any_skip_relocation, ventura:        "10dcbb813af5e8faa8c0355fe162a40d07e592a9b6609f60fe15f1abd0acf93b"
    sha256 cellar: :any_skip_relocation, monterey:       "9ed466077d58280b2d839af41e2ecca05645ca6a74dab770255fe0f1214a6703"
    sha256 cellar: :any_skip_relocation, big_sur:        "33b242790210c71f73232c8ca815b6f7428e1c53821df402a21198c3085b8f25"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7176288210132cc3e627ea299b85c6b0d62c6c6eb44a16dd64e0ec857acd134c"
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
