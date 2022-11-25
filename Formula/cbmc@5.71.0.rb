class CbmcAT5710 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.71.0",
      revision: "a042d91e34e9b18c5edc7c9e575cef7f9bb92c9b"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "abbae6fabd47e314c6a79898109e3482f4a4db704c5f6d4d06ed0608eee5c674"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "bb8b43bcb97c872bf7ccf893022fb833df7c3a0557f8d198a3ac2e40ace109a8"
    sha256 cellar: :any_skip_relocation, monterey:       "4aed33e76c873fb76e8ff635fe0b4836e67c03b9dd9cdb3ef2307f412fd10a8c"
    sha256 cellar: :any_skip_relocation, big_sur:        "25a1f30ecb839f59a06a41336efb5f8fbc8a9d3b8e9692a6e1b88ab60e80c184"
    sha256 cellar: :any_skip_relocation, catalina:       "55c79d069e707c0954d3c076310b5905b7df3e2f9dfd8acec610cda9347b3477"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d92b3818d118dad6fc0e84b8ef0ff14d73659024c55f546908f34b4dcd61c6fd"
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
