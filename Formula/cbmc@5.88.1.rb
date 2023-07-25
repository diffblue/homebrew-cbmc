class CbmcAT5881 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.88.1",
      revision: "b2900b9b3d4c8510cbf45cc6c9c50906396dd419"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "a244831574d89a24e253bdc714d3a23571a4cc5b9b2dceebd2fcb7a9ab87923a"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "41b33eeee8c932dde1d4c7eb36c38a0fdd98598604e6a9abcc6a7826353350fb"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "918dd7778f05bc4db9f96dc3de0884c7096b7d8bc656fdb91ee1716a1ff083ae"
    sha256 cellar: :any_skip_relocation, ventura: "1357ad967e7f2f00cc2d7a936634d8b6ba7a898903c52ddda7c961489b266a63"
    sha256 cellar: :any_skip_relocation, monterey: "ce6f9eb14f82690328f314de10d97c725bbee456e334ea72d1058adffa0aa058"
    sha256 cellar: :any_skip_relocation, big_sur: "7131caabc2be95989e2f8b7f633a11bd219427f5477a1ccea1e3834dd4a6474b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ae2691bf8fb5c04108b4fa728cdd74e4a14fa6069ca36f9aab300cec8a4ddf04"
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
