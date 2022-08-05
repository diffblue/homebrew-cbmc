class CbmcAT5630 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.63.0",
      revision: "3edffedf0781d58eecd33d161084c0f532de6e4b"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c0472a69ace78e3d404159d899d3848c7db7c7414fb9d3c650dd6517b93048f8"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "fabfcd0f87450f4d09460c0bcad60ac9c0e140b312accbe18e73bfdc585bbe92"
    sha256 cellar: :any_skip_relocation, monterey:       "cba638ee8556ba35cd3bc78a16c28525a8f2d08f9164fdd7e66c14f2567d8459"
    sha256 cellar: :any_skip_relocation, big_sur:        "2bda3b21dc33780fc649e61aaccfc4f7fd174fc8fa5ba6679bef4e8fcd829b26"
    sha256 cellar: :any_skip_relocation, catalina:       "aa71f2e424b327557a86674c18fcc5ec41648efded051a635977642f9a439629"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "be417697dd152091dd1945063c513af8a0659e6eb55f3c95f1e17750075e12bb"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  on_linux do
    depends_on "gcc"
  end

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
