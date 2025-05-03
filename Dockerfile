
# Build Command : docker build -t nkabir1986/nginx .
# Base image: OpenResty with LuaJIT and useful resty modules
FROM openresty/openresty:1.25.3.1-1-bullseye

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    unzip \
    ca-certificates \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    curl \
    gnupg2 \
    ffmpeg

# Set working directory
WORKDIR /opt

# Download nginx-vod-module
RUN git clone https://github.com/kaltura/nginx-vod-module.git

# Download matching nginx source (same version as OpenResty)
ENV NGINX_VERSION=1.28.0
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz

# Build nginx manually with the VOD module
WORKDIR /opt/nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/usr/local/openresty/nginx \
    --with-cc-opt="-O3 -I/usr/local/include" \
    --with-ld-opt="-L/usr/local/lib" \
    --add-module=/opt/nginx-vod-module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-threads \
    && make && make install

# Create default configuration folder
RUN mkdir -p /usr/local/openresty/nginx/conf

# Copy default nginx configuration (replace with volume if needed)
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Expose ports 80 and 443
EXPOSE 80
EXPOSE 443

# Start nginx in the foreground
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
