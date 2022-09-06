class CbmcAT5651 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.65.1",
      revision: "f680e0fa669b248db6e103dbafed67a2d3f72807"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "194a7502c192a36e30e777625a6ac9de095312416e2dafe5384cf5eeb376f1ed"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "76fba41e1530d7342736e008da8e970dfb94c906830c311586b70a9999e80f43"
    sha256 cellar: :any_skip_relocation, monterey:       "4cbbd10cd52587ef1d45901db4ae8eb58ac45787d88ebdb948e3337616124454"
    sha256 cellar: :any_skip_relocation, big_sur:        "4671d85edd17f0fb9c9e1823e715323df781cfb4c04a22022df80ac61081d464"
    sha256 cellar: :any_skip_relocation, catalina:       "093942cecaeb52d59cd372215cdfa923a9813910f809e991db2b33c722bcd48e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1e38f41972c30ae3e044caa2d0ad81331548c661c968f476b1d8af48ed8bf322"
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
