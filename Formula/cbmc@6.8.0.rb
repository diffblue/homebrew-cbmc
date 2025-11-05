class CbmcAT680 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.8.0",
      revision: "cbmc-cdee49cb1a32c6d6703cebf6ae67161977264ad4"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "df11f00519de5a81c19b79f58082eaa05341434a3ab1317eefb1b7f6b5cd9ec9"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "03c4abe19406a563f7c1bae781541141b66c7c5d468957b9fdf34b66fa87d5a1"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6ffe8189bcbbe179a6b074eaa632886633804aeff3e0d6b4e67594ba568c3b44"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ed68d6fc6a9f3cb601e9bfbecab74f0c380553fddc67ccfedf726e1810b069dc"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, sonoma:            "372658245ba6d7b874d3014b22e48565274fdf98310298ea0689e390a2c85681"
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle Manifest cbmc (6.8.0)
✔︎ Bottle cbmc (6.8.0)
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "ed7a726069143ab3152fcdfb6d223a501f382f0543a47cb2f92c2a44bcf6b306"
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
