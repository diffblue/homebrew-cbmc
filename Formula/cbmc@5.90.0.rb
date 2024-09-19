class CbmcAT5900 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.90.0",
      revision: "6f1454272b7dffc4e37dc969d65653e69c14f904"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "403fade635af74b4e800edf8bd797eb015ac1691c214ba578baf25816904f276"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e7da11d67eff11522c1c3cdda90afdbedb388ae3dc67c59daee552f5f7d3e506"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "dff038be8969431669d23606a55d00f18ec15eaf3d5bbb3a308405889de66cbf"
    sha256 cellar: :any_skip_relocation, ventura:        "381dc2cb990cda023b27e512146788f68e5a01d53ac6cf62aa9638ad96aa7f56"
    sha256 cellar: :any_skip_relocation, monterey:       "269b165f4f21eee69e82a5a98a763d9c98f04abc55e2b9733690f459805e0047"
    sha256 cellar: :any_skip_relocation, big_sur:        "194bf0b649d264a2ad95932bb4921b97c149a0e3d79fca966f67cc9227985e12"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8edb3b0a8d91d39e93c3256cae07c95f86d76205ffeebb5c7dfc65f24ea70f7f"
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
