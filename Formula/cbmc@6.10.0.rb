class CbmcAT6100 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.10.0",
      revision: "7483d0de40b2f39850f4f5ba5dd9c6e38f959e31"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "588934412ebcbd00bf6c3db2c81657db5cce59090cb4956e9bc22bc3a37149ff"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c84922b33680c53918f3434c9ae7142916245beb8cab54f1ee5df72a8751680c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e1fa69c4139c60cc570abf1dd8b282ba9fabd807521fdf160cb8bfe46ccaab08"
    sha256 cellar: :any_skip_relocation, sonoma:        "4c5f17f1ee097174a3ed7517fe1d5b8d4e7a9d1bc20e1ab4c0bba1a3bf51eaa6"
    sha256 cellar: :any,                 arm64_linux:   "8f5a01eb4f6f50e876b6acf4cd4d6acefbcd03f4475c59d25b8434c4cf36fec6"
    sha256 cellar: :any,                 x86_64_linux:  "abbf802e1fb3054b417da3dbc7ab4b2bc56e61ec23e026167c952847ca6bd899"
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
