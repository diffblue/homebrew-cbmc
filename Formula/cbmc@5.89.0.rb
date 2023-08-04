class CbmcAT5890 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.89.0",
      revision: "1ecce42cace1128ec32744e9cc396e3e8e83a9da"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "43a4e1f2c246338e8d8ded738bc9790a416d24f4a27c4eff5a9356d6940ac02c"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "911cd4e01c711b53375f0e3effea1b9a2c2534424a5a1ca8db078cad20468c00"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "49cf01c74c48b4ac71f6ea8550dfc27434c65e38fec2c7fc0147cf734a116192"
    sha256 cellar: :any_skip_relocation, ventura: "37b3c1dfb419e12a663c7e3dcc501508c22fe7715e5d740dac57fbb22b27f1ca"
    sha256 cellar: :any_skip_relocation, monterey: "43471aa75e9e56c76bc1f3a54cd48efda65d6b943522d81b14cd7a30bee65955"
    sha256 cellar: :any_skip_relocation, big_sur: "563f56d4060194de416598b9a4c0a18ef41b3f77c13627c80b31374af88a2e45"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7fd5cedb3bbf36ae7d0cb2a228cb8e1b233387a52f79b08c8b53d9dba7f64030"
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
