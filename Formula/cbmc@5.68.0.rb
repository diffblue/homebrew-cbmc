class CbmcAT5680 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.68.0",
      revision: "52e004c30dfc8a07bb6154dac182911b573748d7"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a516eaaed960332cfb437dbabe604bd6d7bc0a09ff6dcb8dddea6f10acab2dac"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "4b7bb0db2a9136f54bcfe9f73117f5e0ed0b8089bfdf64726d48dc487e7d16ae"
    sha256 cellar: :any_skip_relocation, monterey:       "0556e974d36fbd216e82dc79b114ce66142b90b584cb00789fc55b3e8cc4faf6"
    sha256 cellar: :any_skip_relocation, big_sur:        "61bffebd03ad6523d98d84ed3d574e592f72ddf886809531c3c9939c8ddd7845"
    sha256 cellar: :any_skip_relocation, catalina:       "7829e83907407629259f8ca1fa3c3c5f917bb47d96199a04392727a95cdb58e6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b641595fcdf69553f27f9e5363b704cc245a42bd684c74ffb454af17950c6597"
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
