# Let us use Alpine for extremely smaller docker images. The less number of packages in an image the less attack vector it has from a security standpoint. Alpine images are below 10MB
FROM alpine:3.14

#By default we use 0.18.1 version of litecoin. However, these can be changed if required eigther by editing the dockerfile or by using build time args
#Example --build-arg LITECOIN_VERSION=0.21.2.1

ENV LITECOIN_VERSION 0.18.1
ENV LITECOIN_URL https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV LITECOIN_USER=litecoin
ENV LITECOIN_GROUP=litecoin
ENV LITECOIN_DATA=/home/litecoin/data
ENV GLIBC_VERSION 2.35-r0
# We grab the sha256 checksum from official litecoin website. For example, the checksum for litecoin version 0.18.1 can be found over here: https://download.litecoin.org/litecoin-0.18.1/
# Similarly you can grab the checsum for 0.21.2.1 from here: https://download.litecoin.org/litecoin-0.21.2.1/
ENV LITECOIN_SHA256 ca50936299e2c5a66b954c266dcaaeef9e91b2f5307069b9894048acf3eb5751

# We need glibc else litecoin wont work

ENV GLIBC_VERSION 2.27-r0
ENV GLIBC_SHA256 938bceae3b83c53e7fa9cc4135ce45e04aae99256c5e74cf186c794b97473bc7
ENV GLIBCBIN_SHA256 3a87874e57b9d92e223f3e90356aaea994af67fb76b71bb72abfb809e948d0d6
# Download and install glibc (https://github.com/jeanblanchard/docker-alpine-glibc/blob/master/Dockerfile)
RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  echo "$GLIBC_SHA256  glibc.apk" | sha256sum -c - && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  echo "$GLIBCBIN_SHA256  glibc-bin.apk" | sha256sum -c - && \
  apk add glibc-bin.apk glibc.apk --allow-untrusted && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  apk del curl && \
  rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*
 
#The below RUN command will fail if the checksum does not match.
#In the below shown RUN command, we have combined multiple commands to single one to keep the docker image layers to the minimum. Each RUN is a layer in docker
#In the below shown example, we use a simple comparison using shell, yet another way is to use GPG like gpg --verify. But then that requires a lot of other packages to be installed on the final image, which can probably make it heavier.
#On a lighter note, most of the variables defined above can be an ARG as well, istead of ENV. Well ARG might be even more appropriate considering the fact that these wont change during runtime but will only be used during build time.

RUN mkdir /opt/litecoin && cd /opt/litecoin \
    && wget -qO litecoin.tar.gz "$LITECOIN_URL" \
    && echo "$LITECOIN_SHA256  litecoin.tar.gz" | sha256sum -c - \
    && tar -xzvf litecoin.tar.gz -C /tmp/ --strip-components=1 --exclude=*-qt \
    && mv /tmp/bin/litecoind /usr/local/bin/ \
    && chmod +x /usr/local/bin/litecoind \
    && rm litecoin.tar.gz \
    && rm -rf /tmp/bin


RUN addgroup -S ${LITECOIN_GROUP} && adduser -S ${LITECOIN_USER} -G ${LITECOIN_GROUP} \
    && mkdir -p ${LITECOIN_DATA} && chmod 770 ${LITECOIN_DATA} && chown -R ${LITECOIN_USER} ${LITECOIN_DATA}


USER ${LITECOIN_USER}

EXPOSE 9332 9333 19332 19333 19444
ENV LANG=C.UTF-8

CMD ["/usr/local/bin/litecoind", "-datadir=/home/litecoin/data"]
