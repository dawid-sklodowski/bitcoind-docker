FROM ubuntu:14.04
MAINTAINER Dawid Sklodowski <dawid.sklodowski@gmail.com>

ENV BITCOIN_DOWNLOAD_VERSION 0.9.1
ENV BITCOIN_DOWNLOAD_MD5_CHECKSUM 7a9c14c09b04e3e37d703fbfe5c3b1e2

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:bitcoin/bitcoin
RUN apt-get update

RUN apt-get install -y bsdmainutils wget build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

WORKDIR /tmp
RUN wget --no-check-certificate https://github.com/bitcoin/bitcoin/archive/v$BITCOIN_DOWNLOAD_VERSION.tar.gz

RUN echo "$BITCOIN_DOWNLOAD_MD5_CHECKSUM  v$BITCOIN_DOWNLOAD_VERSION.tar.gz" | md5sum -c -
RUN tar xfz v$BITCOIN_DOWNLOAD_VERSION.tar.gz && mv bitcoin-$BITCOIN_DOWNLOAD_VERSION bitcoin

WORKDIR /tmp/bitcoin
# ADD install-berkeley-db.sh /tmp/bitcoin/install-berkeley-db.sh
# RUN ./install-berkeley-db.sh
RUN ./autogen.sh
RUN ./configure

RUN make
RUN make install

EXPOSE 18333
EXPOSE 18332

# Check that bitcoind exists on path
RUN file `which bitcoind`

ENTRYPOINT ["bitcoind", "-printtoconsole", "-server", "-rpcuser=bitcoinrpc", "-rpcpassword=testing", "-txindex", "-gen"]
