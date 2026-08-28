class CbmcAT6110 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.11.0",
      revision: "820ff0f555b43fb78e0cd9332e498461bd14244b"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5ab03fc2a5cd0db7367252409b26506ada74e503cff5951ce2a729d14e2f11c6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a0f0b0e2d406b89fd1698d7eadb81de8bad8828e5bdb39fffd0dfe22db50704a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "492b50997cb5e34c2356afca83a14d7364e545919cec46fc264fd20334c43e1a"
    sha256 cellar: :any_skip_relocation, sonoma:        "1690df86daa7e9aef6128c88542949e01914c87090222a0781aef0f01d960854"
    sha256 cellar: :any,                 arm64_linux:   "b03d2387c987ded711c22dc3186c4a6435faa93bf3b03341a110068cbfd3e753"
    sha256 cellar: :any,                 x86_64_linux:  "3b9a421d1236a4417e9dacba5dc36089cabdba8eb0804bad74cbe8b12ffafe67"
  end

  depends_on "cmake" => :build
  depends_on "maven" => :build
  depends_on "openjdk@21" => :build
  depends_on "rust" => :build

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  def install
    # Fixes: *** No rule to make target 'bin/goto-gcc',
    # needed by '/tmp/cbmc-20240525-215493-ru4krx/regression/goto-gcc/archives/libour_archive.a'.  Stop.
    ENV.deparallelize
    ENV["JAVA_HOME"] = formula_opt_prefix("openjdk@21")

    system "cmake", "-S", ".", "-B", "build", "-Dsat_impl=minisat2;cadical", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # lib contains only `jar` files
    libexec.install lib
  end

  test do
    # Find a pointer out of bounds error
    (testpath/"main.c").write <<~C
      #include <stdlib.h>
      int main() {
        char *ptr = malloc(10);
        char c = ptr[10];
      }
    C
    assert_match "VERIFICATION FAILED",
                 shell_output("#{bin}/cbmc --pointer-check main.c", 10)
  end
end
