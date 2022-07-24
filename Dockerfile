FROM alpine:3.14

ENV LITECOIN_VERSION 0.18.1
ENV LITECOIN_URL https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV LITECOIN_SHA256 ca50936299e2c5a66b954c266dcaaeef9e91b2f5307069b9894048acf3eb5751


RUN mkdir /opt/litecoin && cd /opt/litecoin \
    && wget -qO litecoin.tar.gz "$LITECOIN_URL" \
    && echo "$LITECOIN_SHA256  litecoin.tar.gz" | sha256sum -c - \
    && BINARY_DIRECTORY=litecoin-$LITECOIN_VERSION/bin \
    && tar -xzvf litecoin.tar.gz $BINARY_DIRECTORY/litecoin-cli --strip-components=1 --exclude=*-qt \
    && rm litecoin.tar.gz
