class CbmcAT610 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
    tag:      "cbmc-6.1.0",
      revision: "737d5826d29df048493b88caad9b70aa217db687"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "a119d5c644e297b1488f4137bab5ab2423c28ff32a4470def41e2ce2c2d8072f"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "9d7ec59f6ebaad85f7df75140930e36c0d90723f03796cc6bdd9fd3ddf6d0bd2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "791396a6fcb757a4a2d9d28131d2a938238559603e87bb6aa1cbb244b116c08d"
    sha256 cellar: :any_skip_relocation, sonoma: "d894f3d58d372a62a53c354c0d094ea63d0796e9b2914e4b86f82b1cfe68989a"
    sha256 cellar: :any_skip_relocation, ventura: "70cd1877c339a2058822f058758c0097d7d0b3b84040341a1d1378259666a8b5"
    sha256 cellar: :any_skip_relocation, monterey: "b8d8d4173b025674513607e53a24f898d161822e6e07f964b3062b0df75f1147"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "557193c93f255f37b1b0051198aacefb27b6d6847afc722d257e7da9eaf8066f"
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
