class CbmcAT641 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.4.1",
      revision: "cbmc-c902db34beb113815f151c4d1f635e745ac79c0c"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "f0391ab37a95bb557dbb6da68099f790576045c476e57942988f64eeef8919ec"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "e46944311044bddd28635081fb7a6c1979e29308e1b93c145ace4135c6614bd8"
    sha256 cellar: :any_skip_relocation, sonoma:            "8166cb1f18a56d1c37d876ef98c293af148f7d3a57aa447059105084ed2e54e0"
    sha256 cellar: :any_skip_relocation, ventura:           "a4eb663da6492bf729d7b694fdc70a37205f90862721666667a8677b81b54eb7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "5b3641671ef479223faee41b77228c10c3b438419078e718671d42626a6f8198"
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
