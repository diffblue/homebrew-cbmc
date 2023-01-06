class CbmcAT5740 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.74.0",
      revision: "2601e72f2dad8460676d94c45c11a8a3e0824729"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "f0002739e4c96055bb1bc6b5540dde03c48da46f6c1e44bc934281c73c4f8600"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "fc71ae95ac473e8a252105c0ced636bc607762706d3780a2ca0029a01f9cbabf"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "c5030b4217073fd7d50baa42a797470ef649b5321f39b34dccd4dd7582ba40a3"
    sha256 cellar: :any_skip_relocation, ventura: "857d1b7afaecdf948f588157a45febf08800e4031ecdd309b3c2e37ee374c45d"
    sha256 cellar: :any_skip_relocation, monterey: "87e245c720019f41b073c4f1c5f4cfa2b018c0a8178363e6c67990f2e44f975f"
    sha256 cellar: :any_skip_relocation, big_sur: "7bc1d99ae2c8a7ed27c83fba7b5042252a3ce4fb67c5acffe962130aacdefcf3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "611cbbdc0a68bba17e830560d3da83e78cc2962fe3fb29c96276bd3814542a9d"
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
