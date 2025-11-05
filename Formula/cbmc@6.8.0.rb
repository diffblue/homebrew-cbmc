class CbmcAT680 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.8.0",
      revision: "cbmc-cdee49cb1a32c6d6703cebf6ae67161977264ad4"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "62cbb07e544442cab29c1982af3df7ad061aec28a2307d45359c82fbcd47d5c7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "50eb43834405961e997c6d7a9b5ea93eeeec7d91df4e28e9f88e0b6d012a2f99"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "801bab15b77d02d387239b7f533c840e0cfe19d9cd3d89c6c576c486fbc4a5ee"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ffd2deb57750b6ed293e7803aaa970d70eddeb62c1640ffe747e31ac3ac41683"
    sha256 cellar: :any_skip_relocation, sonoma:            "2b179fffc9826a85ac8a7de05a8d1d1c9c83439923ff0478c6fbf4e4e8676f8d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "473f0ee5f97bf663a3a7750ea46185c88120a12c22427958620f9a3eeea6b703"
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
