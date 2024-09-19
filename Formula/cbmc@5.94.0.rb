class CbmcAT5940 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.94.0",
      revision: "a997e322f16566986ec23c4824519c2fee9a8cc8"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "13d5e6de4c94639fdef2a6c71215d9ae32e29ea38ad6b91da6baca29db403712"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "19c4d3aba89c6e9ff9106017dffe793514fb4050ac9ad8cf1c7a2d4242e92772"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "014c6d996002189074f9bfe623df4aeb2c2c29124f6e2b77e25cb7f18cdcc9d5"
    sha256 cellar: :any_skip_relocation, sonoma:         "4d83dbc51c6e54bad0cb8e10977c1201e96179a00e128907a87e2a4b130b36dd"
    sha256 cellar: :any_skip_relocation, ventura:        "96e09c6dfdb45758d11484696b25c9d318110a2bd2f388dfce2977486a68ddc9"
    sha256 cellar: :any_skip_relocation, monterey:       "55cbdf99b4f32326fefd0e0e8c4bfbe9bb5d0f34aec1d186d780cdd725843bb3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "018343ae52dd71492ca3877387f9113eccc91acf0e913a92e7e2c59b18567737"
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
