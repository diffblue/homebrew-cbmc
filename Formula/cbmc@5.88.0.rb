class CbmcAT5880 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.88.0",
      revision: "63b8b71ae8ed1ca86f8db29c5a738923cae1dbef"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "98e2483fa3edc888772803a6c2767b0dcf80b15486dc1be478cfdef93ca91ab9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "4cbb8f633e4913d270ffb8a1f01d05256c3f983f5cac4a0486eebcaf6ee95ca6"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "52f933e55f563b183ecb413dade437fe1c4805dc7bb625cc5b227f36eea26454"
    sha256 cellar: :any_skip_relocation, ventura: "21e4fb7ec538d3b1a9ce042629e73af1282a92f04226c5a8f6dfb57a2a9cc47f"
    sha256 cellar: :any_skip_relocation, monterey: "26c5bb30a5af01efa0f9c28288f3fe1c4db8a59cd8c032d68fd39585fa2a889f"
    sha256 cellar: :any_skip_relocation, big_sur: "2da5c88d1d45976c20dbaee50d04837cf27dacb002cdf0571b3f7f3648c1ba61"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "32fd944bb617085799e4aad950c9f58a5c355a66386da4a51d5533094939c016"
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
