class CbmcAT5761 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.76.1",
      revision: "c0bcc71f5f04f0c72ff95d338cce74eb465c088d"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "44f05ac040c6213c398baf481c19a829b2ccc482843171f038198f186047eb36"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f2352fb816ce9900006859be632fe27e253b26812b4e6ea88b86e1bfd910fe07"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "e4ea1dc9b9853e590d9a431c03fc4e5e84522cdbe96838b766bc5b2e4391f2e6"
    sha256 cellar: :any_skip_relocation, ventura: "e5fe84b2040fa14cae4a93fb09d78d61cb6155760538c505ec3d7f9ea1dc31cb"
    sha256 cellar: :any_skip_relocation, monterey: "0699f198e64ce14e84ce1190ce043256fe346c7b215b61bb2416f84e793303f9"
    sha256 cellar: :any_skip_relocation, big_sur: "810a1c417e7062b979ee841352dc48f1cc035592c63298df4733f2d9715df911"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a26e005deeb943ed17c20daacd0a3161be79ea4869529f6b70b118ab1b05d92c"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk" => :build
  depends_on "rust" => :build

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
