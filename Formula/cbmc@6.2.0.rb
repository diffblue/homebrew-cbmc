class CbmcAT620 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.2.0",
      revision: "27b845c975c6bbdfb2ccc6f40bdfae6793d12277"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "30956c4145093a75694d8fcc912a1119ef3d234660c10984e1f8fccaa053eb36"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "907be43db81eceb8a782915d553cf4aad0c818918d996cf67de4ce88612c0d92"
    sha256 cellar: :any_skip_relocation, sonoma:        "07d5750bccd71dc3a67fe652f835e6bcfa28b09fd373d54e0afcb72bff09c5b7"
    sha256 cellar: :any_skip_relocation, ventura:       "ce8fc9f4c608f740f26d249eb3aece37a6481d83aedb5ebae6b752b007990c0f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3b542bd0684a75380e435ad30ba20d63badb910dcffb0ae3c09e624686db0f95"
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
