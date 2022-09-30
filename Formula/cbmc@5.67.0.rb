class CbmcAT5670 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.67.0",
      revision: "e73fcbbabe46c7fa9c23f56fd527049c6356b8f1"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a8f883fa757a74e5cab64b2a4630a0fef04eb1a5ecbaccc9ccfc28f23f89f1dc"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "9bb265858a9f1c790ee61edf380f3e2e04d73bb0e28675d7f782eafc4c65f401"
    sha256 cellar: :any_skip_relocation, monterey:       "dd16e76d5a4f61be36a577ddd987a721c2e198502c42c1b59da619172667c9ea"
    sha256 cellar: :any_skip_relocation, big_sur:        "1e861b955fa94aee5de8b81f57ff53c700514cc8fe4aa900d749010433885c6e"
    sha256 cellar: :any_skip_relocation, catalina:       "f671160ddd5e32e062972ebee9fc42bb03ed57577e44c1b9ec5c1826194bfcd5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "779681bf2a5616a6c9f8df36010852fedbbfbcbbd8927634a7ff061b46af56c3"
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
