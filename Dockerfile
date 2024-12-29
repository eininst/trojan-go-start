FROM golang:1.23.4-alpine as builder

ENV GO111MODULE=on

WORKDIR /app

COPY go.mod /app
COPY go.sum /app

RUN go mod download

COPY . /app

ARG APP
RUN go build -o ./run cmd/${APP}/main.go

#FROM 基于 alpine:latest
FROM registry.cn-chengdu.aliyuncs.com/eininst/alpine:3.18.2

STOPSIGNAL SIGINT

#RUN apk update
#RUN apk add yasm && apk add ffmpeg


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --update curl && rm -rf /var/cache/apk/*

RUN apk --no-cache add tzdata  && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

#RUN apk add dumb-init

# COPY 源路径 目标路径 从镜像中 COPY
COPY --from=builder /app /app

WORKDIR /app

ENTRYPOINT ["./run"]

#ENTRYPOINT ["/usr/bin/dumb-init",  "--"]
#CMD ./run