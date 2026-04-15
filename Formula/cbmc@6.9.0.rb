class CbmcAT690 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.9.0",
      revision: "cbmc-0656298e0d023347862ada3da078c0447943f761"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "9dec44c27cf36bbba06cba73b763e9297c3f6dba7e09c75909a865179cb1909e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3b467a89494299725283c014c9941758e4862911cb325b4d55f3a709bcd47c02"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "26256e9b458976e9b5e4498c841a2f3dd345b1f98b0b5073cb655e06e36431f3"
    sha256 cellar: :any_skip_relocation, sonoma:            "2280af7134f638b81165bb3da6f8a8d0fce6958835ed0aac5ab2b1a9e2df09e7"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "cca611cefcc25cb55b5758337ba5d7dc378ba07ce8d320c4821f8323e04bbf34"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "9d74a0c53599d2c7938d47d9dfc946ab41b038ecc559a809e347e3b62f3d85e7"
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
