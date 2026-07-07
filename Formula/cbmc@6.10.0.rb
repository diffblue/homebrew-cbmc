class CbmcAT6100 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.10.0",
      revision: "7483d0de40b2f39850f4f5ba5dd9c6e38f959e31"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "46e5946cb90b806b1ecbf1c3cf256815d96889b0d21adc11a0c8c5b108c653ad"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "beb731873f6f287d49e095ce6d19d2b9d194631c83c1e46517571b0e7c9b8c0c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "38ae92b029f8b60744246361fc2674a29fd6e2d9c411dc327686c87a2b1bfc86"
    sha256 cellar: :any_skip_relocation, sonoma:        "e1c4abf4abb3826ef30f36ca828edfcd4bc6d02bdbb1f9f9fb752ebf0a95ae07"
    sha256 cellar: :any,                 arm64_linux:   "a321763e33e1d6a7f0a84c0b5198ad1be7e842ad5c7474849e65bcc9f0493f8d"
    sha256 cellar: :any,                 x86_64_linux:  "e07859081c6696685dd14fcd3773c67a397f9818c9d6f8a709ca3a44f5b2df65"
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
