FROM nginx:1.21.0-alpine

COPY --chown=nginx:nginx --chmod=755 ./wwwroot /usr/share/nginx/html
COPY ./nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
