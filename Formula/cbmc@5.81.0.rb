class CbmcAT5810 < Formula
  desc "C Bounded Model Checker"
  homepage "https://www.cprover.org/cbmc/"
  url "https://github.com/diffblue/cbmc.git",
      tag:      "cbmc-5.81.0",
      revision: "53b50bc5150e428dac0849ddac877738b80397c2"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/diffblue/homebrew-cbmc/releases/download/bag-of-goodies"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "49892e4e8130ee02dc448075565b4453a5bb69c3b5e6ad7ddd8de7e70a45a9c3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "df8c488b1f608b29a5be322eec082f44619b082d9428443667b600529de248a1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "77c6978e39d632f052c218ebf81c3de20d52966f140416521dd357200f9781a6"
    sha256 cellar: :any_skip_relocation, ventura:        "377544fff1d8b885a84b4719bda9dadfc7c929337834596a3e9e884466130784"
    sha256 cellar: :any_skip_relocation, monterey:       "bf60ef97042a599c92211d1cb3c8693dd4ed5dd01b5122f863efdf8f9b197152"
    sha256 cellar: :any_skip_relocation, big_sur:        "4bfd50e96aba5c1ca82b31bf4b0531816d628effbd7ca039b1192021a6dc682c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "22fc1bcffb291bc419b1111be7ecac8548b81fd0e21e9a4b656b9a8641ab803a"
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
