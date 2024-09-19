class CbmcAT611 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.1.1",
      revision: "b3359791bcc1a6651646920c3936ce167465db92"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "60684d6ded939cd178bdd0d1b90abd8f6687a9e86b6db024108ce6e6f8aef102"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "654c911458a7eab3b386b26169b37182e2d7888515863427d3427f9e90f95f92"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "31843516536ee26a864f83afff3359e51f0ed9a8e92ec68ac41f1379afe3b379"
    sha256 cellar: :any_skip_relocation, sonoma:         "6baaccb8d422fc74c8825be26b1ddeae56e8a3a32307c3384d0814050ec1beba"
    sha256 cellar: :any_skip_relocation, ventura:        "34eb37c298433f000ceaeb333a4136ceaa4e0aa8518442392c8eab365e477809"
    sha256 cellar: :any_skip_relocation, monterey:       "6b272860c949fb15a29a790e1a6df1aee28054db9faefb5598859d6cb56f12e2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9b8bf73e3adca3a3e9a8410db4a4040ae78c65e2214717be9de9e04296dba655"
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
