FROM node:12.10.0-alpine

LABEL maintainer="Brian Shumate (brian@hashicorp.com)"

RUN apk add --update --no-cache \
  git


RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY ./arus-ca.crt /usr/local/share/ca-certificates/arus-ca.crt
RUN update-ca-certificates

WORKDIR /app

RUN git clone https://github.com/liyasthomas/postwoman.git .
RUN npm install
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start"]
