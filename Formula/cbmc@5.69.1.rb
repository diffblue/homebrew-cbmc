class CbmcAT5691 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.69.1",
      revision: "74b23a3812eaf57799ba910cd1bdc65d41185e34"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "849a7bac49477422ac11cf4133e900e5b81fdcc4061d3c97554fbbeec44dc9a4"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "34d658585d5fc151682acfdecdf0ed0fec5c58ddb7a79b796960f317cfd648c9"
    sha256 cellar: :any_skip_relocation, monterey:       "94667499b8429c6a29aff90c4c7156362dd55cf11c001707dc814225af808f9a"
    sha256 cellar: :any_skip_relocation, big_sur:        "2436577b09e053ea7f39e76905c0a68d23c3716b3fd796dbdba6b1cd2283159f"
    sha256 cellar: :any_skip_relocation, catalina:       "ba6f921a89dca896aed26a18892b3b3e92f171eb2c13eafc12fcfe68d8c0c3c6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "24197b7557a4ca7b96225969fc3524ba5b1d3d78827bcc721705391a1c2e95e7"
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
