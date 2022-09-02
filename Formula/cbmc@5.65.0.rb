class CbmcAT5650 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.65.0",
      revision: "4e907dd68fc11b189b916e2736a5b3ded54d4c86"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "09a2a842c567c48f5471d26385e785ff097a09ea889c7dc1d6b76459e8d6b95f"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "dc9e9b5b778dc608a7d7e148a6027618dd92edd7e9261659412c74e33cb574e5"
    sha256 cellar: :any_skip_relocation, monterey:       "71904aa86fa2f59ff62b1f538585886342afcc4b511dedb3a155e77733cf1ad3"
    sha256 cellar: :any_skip_relocation, big_sur:        "bdb5b8ea687776239315cca888265cd72f65e22e64457e6f4e7858503f5d9516"
    sha256 cellar: :any_skip_relocation, catalina:       "d60c72d765737b43651c84473565cf8c5381c6e5a3433c345349178d6fdec0fb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "72e17845eccd5bcee96e0d5b8f6b6c780fde959191a07b4e3d7e2c73488601ed"
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
