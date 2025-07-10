class CbmcAT671 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.7.1",
      revision: "cbmc-d148ae6e880a3ef167bb71e9ed28169578899dce"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "e4da41f444470f831db214aa6dad956480e038a60881c78b9e48deeb3fa95228"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "d6661a25684bd574ab5a614470383b73510c5f69206cd91a5baa9c86aeab8f4f"
    sha256 cellar: :any_skip_relocation, sonoma:            "596332470718d88194d1bf9384b1056d6e969ab4ea7a9a75f50ba5e1bb8ac2a7"
    sha256 cellar: :any_skip_relocation, ventura:           "a53575320112d1c682264d76e186f9fce03cced796618dca66611e8e8d9c9fab"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "4de484ea74a4ab92f1cdb50dad18c47329379697441a46ab5f1f3ccfcb7368ad"
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
