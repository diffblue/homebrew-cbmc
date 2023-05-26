class CbmcAT5840 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.84.0",
      revision: "d5e13f1162436b63c24097ef07732cddf8d8acba"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "633ee60ed4d9aac43a1a7bbd693730f61c295c862541ec33b41f078a6b15418e"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c5e50de394864e640f4ca8b78ae1eb25b7deec0efe412ab6ad26aaea88f34a14"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "a0eba2f8e8f26611b05da9d375a201826932d5cb29b8ae1c1e3d89ba6653b84e"
    sha256 cellar: :any_skip_relocation, ventura: "0ac46c3b972e64677a7ebf5933ce062995729a89b956489c00b4cf511dd763fe"
    sha256 cellar: :any_skip_relocation, monterey: "3206cdb2d7e3389e9837388b6fc860c49a7b0ac63b9b27e3f3517676a0f26646"
    sha256 cellar: :any_skip_relocation, big_sur: "590218d2eedaafe549e966bd19d2050d6074465f08065ac3d01fd1b7209aabb6"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ffcf54eb28c83d01793c9608d346111c880ff683ad83884207207f432dedb91d"
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
