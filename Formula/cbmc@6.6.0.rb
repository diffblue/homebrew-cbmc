class CbmcAT660 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.6.0",
      revision: "cbmc-3c915ebe35448a20555c1ef55d51540b52c5c34a"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "e8d12d4f33dd52dcb0cccda25d091e178336bdfb4d2613a0dbb3052ace05f31e"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "53143c96cb703df1c8d1c283cc5a32811cf3abd984bd38afb697b53f73c82ed1"
    sha256 cellar: :any_skip_relocation, sonoma:            "a09fb34fff54907969e84c845dae796c9131e5f08a991f21a5e14902135b437e"
    sha256 cellar: :any_skip_relocation, ventura:           "c56d120a74cd50f94d7c44c4e0b4be15b82c201f60d80a9bca5a8512cb2ac5d2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "7842382106bd523e4a2bf64f090b9ebe1b8d2ba6c1fe5dfecd371e82e4841626"
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
