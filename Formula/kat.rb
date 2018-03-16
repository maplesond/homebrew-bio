class Kat < Formula
  include Language::Python::Virtualenv
  # cite "https://doi.org/10.1093/bioinformatics/btw663"
  desc "K-mer Analysis Toolkit (KAT) analyses k-mer spectra"
  homepage "https://github.com/TGAC/KAT"
  url "https://github.com/TGAC/KAT/archive/Release-2.4.0.tar.gz"
  sha256 "fdaf7da8acc55b396bec5d5592b1a135da4372a661ab708ad1f59a3740245053"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles-bio"
    sha256 "9eca4a8956da34111ac749f86426c8147916add152d89b13acefad48c2e87691" => :sierra_or_later
    sha256 "fdd8b8f9452eac884f6772afc651c141c89885902c284e002e3e2b25a2ce5f4e" => :x86_64_linux
  end

  head "https://github.com/TGAC/KAT.git"

  needs :cxx11

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  depends_on "matplotlib"
  depends_on "scipy"

  resource "tabulate" do
    url "https://files.pythonhosted.org/packages/1c/a1/3367581782ce79b727954f7aa5d29e6a439dc2490a9ac0e7ea0a7115435d/tabulate-0.7.7.tar.gz"
    sha256 "83a0b8e17c09f012090a50e1e97ae897300a72b35e0c86c0b53d3bd2ae86d8c6"
  end


  def install
    # Reduce memory usage for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]
 
    venv = virtualenv_create(libexec)
      %w[tabulate].each do |r|
      venv.pip_install resource(r)
    end
   
    system "./build_boost.sh"
    system "./autogen.sh"
    system "./configure",
      "--disable-silent-rules",
      "--disable-dependency-tracking",
      "--disable-pykat-install",
      "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    cd scripts do
      system "python3", *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kat --version")
  end
end
