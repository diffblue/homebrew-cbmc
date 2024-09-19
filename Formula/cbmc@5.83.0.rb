class CbmcAT5830 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.83.0",
      revision: "535e6b2d266566c47f47339677ac225f39454944"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0451095ac22020cd61611c4024831b9c070e660102ad217bc10188482acd9130"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "af8487cc77ddfa537102628d10ec3e0d05e80d8294fd7d6afb13c514a3637fb2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "20ba7905b6507c86ae352144eaefb3928cf730b1540f975d9c21a062052ea99d"
    sha256 cellar: :any_skip_relocation, ventura:        "ce58502f31b4de7dbe10cd723e5ad484ea3de406433cb5074bd98d38d78092e6"
    sha256 cellar: :any_skip_relocation, monterey:       "1f1d5ccbe76e8ffe30d5cecca72318b260a133b4d12d9934b63e55af0a7070d9"
    sha256 cellar: :any_skip_relocation, big_sur:        "ec82be5d195f73b561e5a58a943536454e9514814f0172a03f0c88bdd4719816"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "58ce745f65d39b93c547979c2c786ee3c3998feb38a2b4f20b3bc817ff29afa8"
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
