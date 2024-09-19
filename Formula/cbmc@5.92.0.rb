class CbmcAT5920 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.92.0",
      revision: "671e46a67401970aacc937f9c9284ae845289471"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "14a9ab4826a75f7caba944dc714a1d0c789e4dd13cc9f9f7a75d79ef7d262903"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a867f83662ae5452a7ed2a955c8fe607f3304f892439830bf8d1a5d298338775"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "f7d463c80eed41e0faef67b5388878b472e1846823b4cfbb61c67b9957e698ed"
    sha256 cellar: :any_skip_relocation, ventura:        "7425e182a392d0868c5fda04af734ad1ac27b2438744ca295d36ec55471511ef"
    sha256 cellar: :any_skip_relocation, monterey:       "8b9ca653db51ef3b9bee91849963ba8150c51b332e56ce5cfc4c2aae257cf720"
    sha256 cellar: :any_skip_relocation, big_sur:        "5316d40267a77de2e13e90553146a61c8102620d839e5a4a544f223672654305"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b01aa4776d6f070aae280ca025fd5e883327cd1ad129d4231b19f5887fb30542"
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
