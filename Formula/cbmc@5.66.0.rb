class CbmcAT5660 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.66.0",
      revision: "c3a57ec2671f603f81ae2cd593edef1ae1abcf52"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "cbe028229e229d05ff5f7d14a56045b8b074494adca29449b452e39fbde5fc49"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "4d5e002ae8e9cb4cec985993c5d59c54911e358af47bcb4f4567481aa6c376fb"
    sha256 cellar: :any_skip_relocation, monterey:       "1783c4a8c4e6772590ed2932d0d9a59ef824cea29bed62512a02fb3ac5c04a24"
    sha256 cellar: :any_skip_relocation, big_sur:        "197bd5404450c5059449e8d9bab9cd4dab5e3abc16641dd904ca99c3540cc1b6"
    sha256 cellar: :any_skip_relocation, catalina:       "d548fcf950f8bd755a79c7824072ae9a6162fa2ebccdc02ffe24088b89171aed"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "bc2ec0886559e8fed4806a13ef256bd6877b0d6fb555f90b7c8aefc108e3d451"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

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
