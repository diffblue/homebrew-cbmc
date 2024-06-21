class CbmcAT600 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.0.0",
      revision: "a8b8f0fd2ad2166d71ccce97dd6925198a018144"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "d7ff36ff1676456e7d68edad8ee1dd81dd4a496341a16df072ba150fe3a1281e"
	  sha256 cellar: :any_skip_relocation, arm64_ventura: "c69f05a52c886f05426be4df86c3ab1a3fd63cbe9a679615608cbf681a21c0a2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5aa36022cb3a646d9399332a791a6b8b44c867ac28c536c58c58d83d8dfb6182"
    sha256 cellar: :any_skip_relocation, sonoma: "58f43ad483a753d6aa3e5d64f147b0bfd1cc8da18e50c62213a6a2a8c93c430a"
    sha256 cellar: :any_skip_relocation, ventura: "4b5634d2723b176ef3ac6494b25ab8159ceb5f4f1b1ecc26ebb97f232e202bfd"
    sha256 cellar: :any_skip_relocation, monterey: "6c43cc846e5c7a1276a8142438e88b53b74815643d55d63792f1f8275f27af58"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9861370f9e79ff9c8dfbbdece78628dc70f6a6f25250c53dc6dd6819ffda58bb"
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
