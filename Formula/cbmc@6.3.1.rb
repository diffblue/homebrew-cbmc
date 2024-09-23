class CbmcAT631 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-6.3.1",
      revision: "cbmc-d2b4455a109383562735cfb8b52ed8a6d2b6e197"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:      "cafa46eac570b518e09a3a259f08564cf628440de748db7a7ee97e355c69f91f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:     "9caee22e3e5d624f92fc66a19375481e9f9cd062f236af1ea38c11963b86ca34"
    sha256 cellar: :any_skip_relocation, sonoma:            "f223546676fff726c4759f6ce118d03369706b8fa9b0869d8baac33624dd3aca"
    sha256 cellar: :any_skip_relocation, ventura:           "64b75d623aece2d92aeb771252fe3228f8e87a2ac5cd989365192f87bdf5d360"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "4acc40ac65e85947a6a62fff832a5842fa73fe10acc6cb827669c0d5e646ae96"
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
