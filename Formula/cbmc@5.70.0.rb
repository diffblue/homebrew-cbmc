class CbmcAT5700 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.70.0",
      revision: "266b63313799a63d3348c086b7a4b42cc3fc251c"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4f3230565ea50e48315403d2e9ba94d4921ea4e32f1ee448722b49df187caed7"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "1ec1d90263c27207aac1bf267eb1632aa00ebb40317de9281f6e006bfe7544d7"
    sha256 cellar: :any_skip_relocation, monterey:       "6922b60662b0c3114e52bee17b925467e27590d58e949e793d8ea4da7fc1d896"
    sha256 cellar: :any_skip_relocation, big_sur:        "668c7a615b29aec6089c9c73bb16ca56dd030ed7c12662b5ee38307d126bc697"
    sha256 cellar: :any_skip_relocation, catalina:       "98248954d9b81bc840ce2b2ead4633650e227ba91dcef350558b9d3608985ef5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f48cb09ac6c9024ecbf08f6e9b2e72e7bdc0183b91e6699743ea7d9530be7949"
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
