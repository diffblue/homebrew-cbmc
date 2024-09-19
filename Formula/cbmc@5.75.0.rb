class CbmcAT5750 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.75.0",
      revision: "db721b26a41348f22e9d79f363216054264e6d8d"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "badf74a9a7ace18ed9532ec25df7ed16377b67eb6463914cc43e93f7236a8d27"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f636390cd2da664d8702242caa0b47afb6d6722e060ee87c2761d3ee07a748fd"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "8432f43352e9ec26114ee86c6b622f1b3a39fd8a7414251d80c71c27308f580d"
    sha256 cellar: :any_skip_relocation, ventura:        "363496769aeff32f195aceb74ef68acd262d0929501d1b9777ba2eeb7455e797"
    sha256 cellar: :any_skip_relocation, monterey:       "88a5343137564dffb464887d34ce7ee2e44a5b56695c1dbf1b67683676fa245c"
    sha256 cellar: :any_skip_relocation, big_sur:        "f15b880c992bef5012f23dd17e08b0e9f56907f5c874825fe06a80feab30ae46"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "643a52e06219430ec2461f0143d84b968a2563f8bbc96b5304f824278535f95b"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build
  depends_on "rust" => :build

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
