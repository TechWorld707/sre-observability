FROM nginx:1.27-alpine

RUN apk upgrade --no-cache

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY app.js /usr/share/nginx/html/app.js
COPY styles.css /usr/share/nginx/html/styles.css

EXPOSE 80

CMD ["sh", "-c", "until wget --quiet --tries=1 --spider http://backend:8000/healthz; do echo 'Waiting for backend service discovery...'; sleep 5; done; exec nginx -g 'daemon off;'"]
