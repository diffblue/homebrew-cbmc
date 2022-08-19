class CbmcAT5640 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.64.0",
      revision: "8fbba35f27b9b3efb78f3b875ba27bf4ea6fe641"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f8ad0d2998bd8c0912b44f934971a759f246bdd75cf262583264eae72a0e2e37"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "04747aa18a76adbaab78a67a817641f52a20e2a9f5ad0feb6fa50f14dbfc84ab"
    sha256 cellar: :any_skip_relocation, monterey:       "7223211e59041b35a5fbbea35845f491b9c30174a65c5459d95c98473cc850bf"
    sha256 cellar: :any_skip_relocation, big_sur:        "80e0fffe41745e2e2538803173381255c5960d6af0f28b37d6023a2eae797334"
    sha256 cellar: :any_skip_relocation, catalina:       "b2ffe640a432284e7be95300365df31a53eb32a0826563804b874a9d4c289b94"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0797247f218de07871aec44b28155faadf2e0e55c650c9b10947eb09e344c161"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_linux do
    depends_on "gcc"
  end

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
