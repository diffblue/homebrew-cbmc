class CbmcAT650 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.5.0",
      revision: "cbmc-32143ddf8ae93e6bd0f52189de509662348c2373"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "f259250d22a5f48cadda43e5a2dd2706fde38f53b4217d97b0307e996119dd30"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "a93e85531279bc7ad21e820e14ab9dba7721fb672468ff06271376e38db951a4"
    sha256 cellar: :any_skip_relocation, sonoma:            "46db7a0ff3cd5a19deef410745a316fc490b308fc32d54c3c345ae6cea74af7f"
    sha256 cellar: :any_skip_relocation, ventura:           "816805e204ae857ec575e0204ebd2781c6c3fef8526096d022bfa5a7ab13198d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "7f375f1f46d0b9d3d83d7f89a5476e08c16c260eb0fe3d04711972efe0eec25d"
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
