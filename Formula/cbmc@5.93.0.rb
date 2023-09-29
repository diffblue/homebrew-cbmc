class CbmcAT5930 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.93.0",
      revision: "99c54024b4911bfb2c6ed4fbdbe33d199389896d"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "853e3ebba7f249f6240954e65b0802e2b08f2114301ca461d3ce27417af32e3c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "091b548aa6550022348be557f99951216f5c4255397975bc681d45d7b394302b"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2624ab204220da50ae31f682c267fd46de87ae33fd014819f61598715f93493d"
    sha256 cellar: :any_skip_relocation, sonoma: "e5f308a74ea94e8049aa5c0a90cef52c97e40ab22260d838c67ba420cfc1a38e"
    sha256 cellar: :any_skip_relocation, ventura: "4e7b32a03f293874fb3fc72885a1cad73912522d33b389792dcfaae6878c6c1c"
    sha256 cellar: :any_skip_relocation, monterey: "d627a208d03c9b2b641094b3784eeeea8be508e88f5376cda7720df8a88d463d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "472abc801f35a9f786e8d260d2656bc1a60c4064b986a73e1ef9bc4f17e56e75"
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
