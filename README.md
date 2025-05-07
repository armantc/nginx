# nginx
Nginx customized for VOD

Buidl:
docker build -t nkabir1986/nginx .

Path for Certificates:
- /nginx/ssl/fullchain.pem
- /nginx/ssl/privkey.pem

Config Path:
- /nginx/nginx.conf

CDN Cache path:
- /nginx/cache

Can use environment variables to configure with format ${VARIABLE_NAME} , and automatically replaced by
docker-compose environment variables