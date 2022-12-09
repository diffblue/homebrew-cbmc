class CbmcAT5721 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.72.1",
      revision: "de504f532f407b51fcdb9ef7ec61b4bae4fde49e"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ef3e731026e9c5fa0794ed6a179ae3bf7c83ffa5dee82a7db1033da31ad24e02"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b59b2df309ff65320de988bd58bb8f2367afe88e36a0f32e749d637262a8a9f2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "676daa979f2fc6feaec8fa4adc17d880197d5bc28848d5351a03dab38d81aae4"
    sha256 cellar: :any_skip_relocation, ventura:        "176d7d8d084cc58f92c89f08759343bc4f6fc05a88049d6f9d2b706f68c55621"
    sha256 cellar: :any_skip_relocation, monterey:       "f3674f5a757d3809f6ad1da8d35d244446bb17541d85fc9e469b5409191448de"
    sha256 cellar: :any_skip_relocation, big_sur:        "03f69a32fbc2e9ea975f6e609a8626afee8441408d424786b8736acb6635634e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "13a9fb067d601bb48da62ca44cdbeff0b71a8d0c212eea7b406a9971dd3a2a04"
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
