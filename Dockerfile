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

ENV NGINX_VERSION=1.28.0
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz

WORKDIR /opt/nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/usr/local/openresty/nginx \
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

# Copy nginx.conf
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

EXPOSE 80 443

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
