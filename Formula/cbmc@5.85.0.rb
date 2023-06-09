class CbmcAT5850 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.85.0",
      revision: "2830a3bc8e1e8033ddd74cfd3dcbe1b7cceeeacd"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "9bf991e26cebea084b7798709e6d54cdc44638d047897e86d9ff0e0918e5b9c2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d0dd7142ef47db847b6e376c1451fe7d4c664ecedd2519e64d87a4a4a2b1dde2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "8eb09483dd77a28f7ea4817a1740adf9b50e59680b2717723640089ffcfee0ea"
    sha256 cellar: :any_skip_relocation, ventura: "2b65b7eb6f13a74f2cdc67bf10fd66e7c8f40ddd39330da6b8f6f7c18bf82ef7"
    sha256 cellar: :any_skip_relocation, monterey: "0fd8e7b84476d43e869f3524d85cc10605fd3ae731196cd887f03a492b36219a"
    sha256 cellar: :any_skip_relocation, big_sur: "d8574bab29957218e43727a7950ba313c16f09ee03fdf0179c89e6d47214dc06"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bf38a4162cd69b55866e134035e01bc52ddd0e1786cc623748a7dd48af66b68b"
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
