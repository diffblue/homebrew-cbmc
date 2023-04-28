class CbmcAT5800 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.80.0",
      revision: "a9785d3e25e5a1b20bc85a3ba02a6207751929c4"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7c916feede07c4cff599d1389436f9a1bade6cf401502c9797c9619113b5fc17"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "979742467d9c866bb9a938d65149a8bf6c01bcaae9d1e43588a57110f5b2c8d9"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "59c8f5afad101b3fc610f8cded6945fb317d6cf7f65620b6b12c890797d325b2"
    sha256 cellar: :any_skip_relocation, ventura: "7bfa9700ec7a5f3d0e12131546803aa8ed1248c0cd233c4b1afc8fbd185dec42"
    sha256 cellar: :any_skip_relocation, monterey: "bb7b84407c60bc334cf0f1de14b16954b8a91684cdc1dbd02e0cd701a5d0e77e"
    sha256 cellar: :any_skip_relocation, big_sur: "b08ba5cbc2e4a37ada324626449a187281475b90eecc95ff7c7a90f2d1f0ace9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "cd5d24d635d4a0e78051bf1f5e76306fa831083b2509ec8495f9e988c57c6486"
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
