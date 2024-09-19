class CbmcAT5910 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.91.0",
      revision: "3e3ba26f238f4bd27cff3923039dd2d21d6d7328"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "24415d3cc6aca1cedda81107f0153e58c349d25cf502396db1ce8a5fabc51634"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c5014604aab8eda675de25eac7d4e319b7d268262f0ce47f71b49f6616302adc"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "8628c5a621cd22f471344f202ec6dbae801223cc01e419178dbba1e2b8c7bc6c"
    sha256 cellar: :any_skip_relocation, ventura:        "21cb1c1776241115571ee1493feae46e4953131d6652de2cf5bbbd9efa0a53d7"
    sha256 cellar: :any_skip_relocation, monterey:       "76570db58603f83baa1da7f7a0c498711cc5480ffde228aa6fb50862bacef984"
    sha256 cellar: :any_skip_relocation, big_sur:        "0858f3c63dbd74c728ce70edd5946e7048f965d4802305c8f52a6317612da1fe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dac88627c56f0a6bdd409c839a22b3024089c7b44b300799e8c1ac099ee3b96e"
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
