# Static site for bchanot.fr
# nginx:alpine serves index.html + CV (HTML + PDF).

FROM nginx:1.27-alpine

# Custom nginx config (gzip, cache, security headers).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Site assets.
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*

COPY index.html ./
COPY CV_Bastien_Chanot.html ./
COPY CV_Bastien_Chanot.pdf ./

# Non-root hardening: nginx:alpine already drops privileges to "nginx" user
# for worker processes. Master runs as root only to bind port 80 inside
# the container — fine because the host port is the one exposed.
EXPOSE 80

# Basic healthcheck: nginx must serve index.html.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
