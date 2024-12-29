# Dockerfile - alpine-fat
# https://github.com/openresty/docker-openresty
#
# This builds upon the base OpenResty alpine image that adds
# some build-related packages, has perl installed for opm,
# and includes luarocks and envsubst.
#
# NOTE: For envsubst, we install gettext (envsubst's source package),
#       copy it out, then uninstall gettext (to save some space as envsubst is very small)
#       libintl and musl are dependencies of envsubst, so those are installed as well

#ARG RESTY_FAT_IMAGE_BASE="openresty/openresty"
#ARG RESTY_FAT_IMAGE_TAG="alpine"

FROM openresty/openresty:1.27.1.1-alpine

ARG RESTY_LUAROCKS_VERSION="3.9.0"


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache --virtual .build-deps \
        perl-dev \
    && apk add --no-cache \
        bash \
        build-base \
        curl \
        libintl \
        linux-headers \
        make \
        musl \
        outils-md5 \
        perl \
        unzip \
        wget \
    && cd /tmp \
    && curl -fSL https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && apk del .build-deps .gettext \
    && mv /tmp/envsubst /usr/local/bin/

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    /usr/local/openresty/bin/resty -e 'print(package.path)'
#    /usr/local/openresty/bin/resty -e 'print(package.cpath)'
ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"

ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"

RUN apk --no-cache add tzdata  && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-template
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-redis

COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx /etc/nginx/

EXPOSE 80 443

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]