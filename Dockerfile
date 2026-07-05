# Static site for bchanot.fr
# nginx-unprivileged serves index.html + CV (HTML + PDF) as uid 101 —
# no root master process in the container (tag + digest pinned).

FROM nginxinc/nginx-unprivileged:1.28-alpine@sha256:209331cfcaec00da781f5b8a38e0d1c0abd00cb2b51e6ad385a30abbbdb04e15

# Custom nginx config (gzip, cache, security headers).
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx-security-headers.conf /etc/nginx/snippets/security-headers.conf

# Site assets — clean the default content, then copy ours.
WORKDIR /usr/share/nginx/html
USER root
RUN rm -rf ./*
USER nginx

COPY index.html ./
COPY CV_Bastien_Chanot.html ./
COPY CV_Bastien_Chanot.pdf ./
COPY favicon.svg favicon-32.png favicon.ico apple-touch-icon.png ./

# nginx-unprivileged listens on 8080 (>1024, no NET_BIND_SERVICE needed).
EXPOSE 8080

# Basic healthcheck: nginx must serve index.html.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
