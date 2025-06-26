class CbmcAT670 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.7.0",
      revision: "cbmc-5d1438a883201a8983b1449eb2485df0821c819d"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "35eea2d62dae6e2e86d4dbf92ec5111edda05063ccda1ae0d9f4687c5cb9f0bf"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "f640cb2bb99f19d886b8917b8c23a16a4ce1dcff0b9b381e010de7c701d42d0b"
    sha256 cellar: :any_skip_relocation, sonoma:            "613b16605e01110616ea2d884c1f6a6dde735092e32b437146ca44c3c58d19bc"
    sha256 cellar: :any_skip_relocation, ventura:           "b120f6cd2b28a57953da930c082ac21709f947b0692fa4032f8f556905944251"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "55dfcd2ddbebcee3cf6291a267cca66c6af5f8370a35d6fc62051a775df43066"
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
