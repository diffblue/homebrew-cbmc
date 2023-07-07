class CbmcAT5870 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.87.0",
      revision: "5650fb9e116291b44da32341db4288a3bcff0fac"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "7c7e0572f70b256bfa23b3976fa9ffc2ebdc56befc9cfbe7d62388ff6a415ef2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1edce00fbfd63cd26d3b1bfa2b2f25a608ee6f11e9809dbbae435410c336361c"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "4bca9c73c9985c982db368a826121bc19a3e61eae964549ab709d999e3b33f08"
    sha256 cellar: :any_skip_relocation, ventura: "c3f39eefced46c5276bf13e78798b748822b9f865e5d34340f0da49f03c03e93"
    sha256 cellar: :any_skip_relocation, monterey: "1f7d5b8dc17f0ede3f9a661b0f2b0922b17a2e03bd61928901c252d88f0def9f"
    sha256 cellar: :any_skip_relocation, big_sur: "6185116e76b71f0497d6d93a96766a9ba267871c92764c26c8334c5cadfd8291"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b6acdbd08d06f8892e930c7be3f22266f7f784e93fa08c19fbd2f300c2b71d92"
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
