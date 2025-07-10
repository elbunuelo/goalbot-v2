#! /bin/bash
set -e

LIBRESSL_URL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.0.0.tar.gz"
RUBY_URL="https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.2.tar.gz"

LIBRESSL_DIR='/usr/local/include/openssl'

apt-get update -qq 
apt-get install -y build-essential ruby-nokogiri 

mkdir -p /tmp/libressl
cd /tmp/libressl
wget $LIBRESSL_URL
tar xf $(basename $LIBRESSL_URL)
cd libressl-4.0.0
./configure --prefix="$LIBRESSL_DIR"
make
make install 
ls "$LIBRESSL_DIR"

mkdir -p /tmp/ruby
cd /tmp/ruby
wget $RUBY_URL
tar xf $(basename $RUBY_URL)
cd ruby-3.4.2
LIBS="-lssl -lcrypto -lm  -lc" ./configure --with-openssl-dir="$LIBRESSL_DIR"
make
make install
which ruby
ruby --version
ruby -r openssl -e "puts OpenSSL::OPENSSL_VERSION"
