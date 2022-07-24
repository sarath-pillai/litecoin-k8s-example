# Let us use Alpine for extremely smaller docker images. The less number of packages in an image the less attack vector it has from a security standpoint. Alpine images are below 10MB
FROM alpine:3.14

#By default we use 0.18.1 version of litecoin. However, these can be changed if required eigther by editing the dockerfile or by using build time args 
#Example --build-arg LITECOIN_VERSION=0.21.2.1

ENV LITECOIN_VERSION 0.18.1
ENV LITECOIN_URL https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz

# We grab the sha256 checksum from official litecoin website. For example, the checksum for litecoin version 0.18.1 can be found over here: https://download.litecoin.org/litecoin-0.18.1/
# Similarly you can grab the checsum for 0.21.2.1 from here: https://download.litecoin.org/litecoin-0.21.2.1/
ENV LITECOIN_SHA256 ca50936299e2c5a66b954c266dcaaeef9e91b2f5307069b9894048acf3eb5751


#The below RUN command will fail if the checksum does not match. 
#In the below shown RUN command, we have combined multiple commands to single one to keep the docker image layers to the minimum. Each RUN is a layer in docker

RUN mkdir /opt/litecoin && cd /opt/litecoin \
    && wget -qO litecoin.tar.gz "$LITECOIN_URL" \
    && echo "$LITECOIN_SHA256  litecoin.tar.gz" | sha256sum -c - \
    && BINARY_DIRECTORY=litecoin-$LITECOIN_VERSION/bin \
    && tar -xzvf litecoin.tar.gz $BINARY_DIRECTORY/litecoin-cli --strip-components=1 --exclude=*-qt \
    && rm litecoin.tar.gz
