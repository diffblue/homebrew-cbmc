class CbmcAT5951 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.95.1",
      revision: "731338d5d82ac86fc447015e0bd24cdf7a74c442"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "92bb1f8cc02bad88bd71845a615a311747c44c20449860543e05742268e06449"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "103f86dde81bc92368e10ab5ec0fcb6addd771dd85839f490fcde72fd512cefb"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ec0b3ad59689b24a9d003b0f4d15994018989da3fce5fd4d7713b37383bbaefe"
    sha256 cellar: :any_skip_relocation, sonoma:         "b81523cf245ba04dc8e17152f27f91397f65712c279b0dec569014726bd35923"
    sha256 cellar: :any_skip_relocation, ventura:        "35258a857e982e4b3b6aa365c70d6dba213e1900c185412651ce429ef1af4fc6"
    sha256 cellar: :any_skip_relocation, monterey:       "94a2e38a53ad76739e41981ae4097ce4a3aee732988e589fd71287f621836c77"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a8e785b5f7b674f40d3ef03f40d3a94b191b42348c07555b1548b55b37550c6c"
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
