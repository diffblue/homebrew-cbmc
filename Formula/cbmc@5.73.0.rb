class CbmcAT5730 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.73.0",
      revision: "3d8c1f891e09a969071dc87d01991b95a9b4a037"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "3630f8e137169247536d4f26437f77f99c0ca2040b1aee6a54c01aadbd574aae"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "6573be59317f93d892710f2ca9e3b1f5d8c88eafbce53c77d2f98f393b87a3e0"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "f6d9a803c1f4b85ceb087d8610a846e2a500277426c62c203eff964765b493b4"
    sha256 cellar: :any_skip_relocation, ventura: "0a4b3dc1037ab668f748126e09d66f1ffe0d1bce0a4ae12d77794eb72337d72e"
    sha256 cellar: :any_skip_relocation, monterey: "780611426522ea7d7934b939fe9dcc190956cc17558c236fa32814679044ee81"
    sha256 cellar: :any_skip_relocation, big_sur: "b43b935931bd0079b4ee53defc52cda331f231a63d64cdbd05617f6e26137af9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e93a5083fc1f71683102d6c96ba1b7cee0d9caa9f705392532de53c6ccdb39d6"
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
