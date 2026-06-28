FROM alpine:3.22.4

RUN apk update && apk upgrade
RUN apk --no-cache add nginx
RUN apk --no-cache add openssl
RUN mkdir /etc/nginx/ssl && \
    cd /etc/nginx/ssl/ && \
    openssl req -x509 -newkey rsa:4096 -keyout nginx.key -out nginx.crt -sha256 -days 3650 -nodes -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42/CN=www.masase.42.fr"
COPY /conf/default.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]