class CbmcAT5790 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.79.0",
      revision: "4af9c8a54867ca76e8c22d218d4eca2eedbf8d5f"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "23150650b9d2d289dd915c91c046877bf11397e859f512330a56a5217b128dd0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5701f3c7d3ae473a6d2bee21d97cf5b85c4ab73aa19ca8a652c0fc6b9905778b"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "48e393185ee00dc0332933ad856c9bc9ed97eea751b7b40a9d4fbfa7fcb0a53b"
    sha256 cellar: :any_skip_relocation, ventura:        "3bc134daa8eed1455613c26721ed5e9028d2609cd627f3c1948e8c2633fa1762"
    sha256 cellar: :any_skip_relocation, monterey:       "c4cf4f66d4f70322bfa5152eec4c0f42b34fe5ecc4e7c0319a7428c561ddfd03"
    sha256 cellar: :any_skip_relocation, big_sur:        "26b8bfbf20672c8de30ab33828443e23d352e38d45fe9fe175fbf12b5386387b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "55a01796593a0448416402e994b484e5d18a2cd82772f6591720422dbd92b6b2"
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
