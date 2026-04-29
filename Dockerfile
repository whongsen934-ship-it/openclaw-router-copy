FROM node:20-alpine

WORKDIR /app
COPY package.json ./
COPY server.js ./
COPY config.json ./

ENV ROUTER_PORT=8402
ENV ROUTER_CONFIG=/app/config.json
ENV ROUTER_LOG=1

EXPOSE 8402
CMD ["node", "server.js"]
