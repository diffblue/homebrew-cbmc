class CbmcAT5610 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.61.0",
      revision: "8f147113c34b06a03e1308b5ef4f5a496f76cd6a"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d4fdb2d57c22db2f6ac4cc283a1919fd252dc6c48e8b4a7105ffeebad135315c"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "ade48450854303181eddead160e7c013ebcf31cb4a8480bb706ae1d387a2f58d"
    sha256 cellar: :any_skip_relocation, monterey:       "c4b4d89374036136282afd4930cf40729562aabbbcd86fd04b35c4865c127115"
    sha256 cellar: :any_skip_relocation, big_sur:        "a33f8c3d7bcc587b3abc6ffa1d0b45e61f77142edf01d03af6456cd39c3b8597"
    sha256 cellar: :any_skip_relocation, catalina:       "0b803cf1e86687301b7313681112ed0aa263b12706ab2b3e46fd7f93eb3a0bf3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f4f1537dae8018ebb26667964d0c88cfc55896e9513d459f7098472ac643ee22"
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
