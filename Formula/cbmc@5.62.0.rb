class CbmcAT5620 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.62.0",
      revision: "64034e0d47f5d79b67fb22310a0e785469d24f01"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1567d801a588d5e8b67f102afeb8c8429309d26ef0146bc902bbaf7588319ece"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "35df182be969328dd039ea8e0ebf75873d2f5b1e9e0e1c47a6c1b0403c1f961a"
    sha256 cellar: :any_skip_relocation, monterey:       "2cf670b330b2e915450eb4d098337d73721ceed1d5cb7822b27e624f1de4eecc"
    sha256 cellar: :any_skip_relocation, big_sur:        "ca60a37a54a9f46f3856a956b653f74a91eacdf870de592675a5c58c697e1256"
    sha256 cellar: :any_skip_relocation, catalina:       "f48df2ae2fbea7fc977eb5cb5b8463d224909bd491547f7835f51d8230355afc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3ef7261f3254aac265f02025506be2839c1275dde190ae4b74695388162c46fb"
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
