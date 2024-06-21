class CbmcAT601 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
    tag:      "cbmc-6.0.1",
      revision: "0761608baaa477b502c43a213a1cb31639756e95"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "91db0b6ed1ceafc16d525d7826a9c41ac38493c1d72637ad925173989f4865e9"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "852a1c4f9869f25587973f2ef10b8a9b85a9e4dd0e3dd97657eba488b5d4f708"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e85fb98a34864d6011a72e05aacedf38d5453068d08318da9fee65c6a84ae93b"
    sha256 cellar: :any_skip_relocation, sonoma: "63ea43eee8eead0a611a8d260986cf940c640a7b88948f93286537bbb3078c75"
    sha256 cellar: :any_skip_relocation, ventura: "038cb15f93290f3be814477ca1bcabc146ccc8a690fd377115b0cc6d45ca7a03"
    sha256 cellar: :any_skip_relocation, monterey: "665fe2285610f7f479e9bc0f5db6cbb2822ecf137ae60ec416fef444ed2ed81b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0be04e3a71888a64bedd14a2c14b49d21154ea96345441aa9ad98cb30ba8e520"
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
