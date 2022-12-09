class CbmcAT5720 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.72.0",
      revision: "9a84d62dabbf92e2a0e83bec136b9c6d73d6f2b1"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "632b3fc48dcdecba047f2210af8707eefd20cc15c11f8d1fa1fb8033c6d8f29e"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "8ac53f43921cd3e685fd258d7acabbef536ef5e49d7528d48863d3b01c8233b3"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "64beb8c577c7d8fbe9b13f816a96ef95e195c8513f63d5767c7c5e051590460e"
    sha256 cellar: :any_skip_relocation, ventura:        "1f26b1af4ac0a48dd5461f703086a465498aa51e3731e8fa251359ddbc3d29de"
    sha256 cellar: :any_skip_relocation, monterey:       "6f89c60dfd5b04deaa53da02dd639818178c6843b617bc90a9512c39312eee95"
    sha256 cellar: :any_skip_relocation, big_sur:        "f22684eac933f1ea04b490b79d477b881e246811d79b339e910f0e9d9b355763"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "31499da4642bcd6f60a5df48b2081465a2b1eacd2fb9d99d934060d37ad79111"
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
