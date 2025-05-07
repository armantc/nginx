# ----------------------
# Stage 1: Build
# ----------------------
FROM openresty/openresty:1.25.3.1-1-bullseye AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    unzip \
    ca-certificates \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Clone and fix version of nginx-vod-module
# Download nginx-vod-module
RUN git clone https://github.com/kaltura/nginx-vod-module.git

ENV OPENRESTY_VERSION=1.25.3.1
RUN wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
    && tar -zxvf openresty-${OPENRESTY_VERSION}.tar.gz

WORKDIR /opt/openresty-${OPENRESTY_VERSION}
RUN ./configure \
    --prefix=/usr/local/openresty \
    --add-module=/opt/nginx-vod-module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-threads \
    && make && make install

# ----------------------
# Stage 2: Final image
# ----------------------
FROM openresty/openresty:1.25.3.1-1-bullseye

RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

# Copy only nginx binary and modules from builder stage
COPY --from=builder /usr/local/openresty/nginx /usr/local/openresty/nginx

ADD https://github.com/kreuzwerker/envplate/releases/download/v0.0.7/ep-linux /bin/ep
RUN chmod +x /bin/ep

# Copy nginx.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

COPY hmac.lua /usr/local/openresty/lualib/resty/hmac.lua

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/ep", "-v", "/usr/local/openresty/nginx/conf/nginx.conf", "--","/usr/local/openresty/bin/openresty", "-g", "daemon off;"]