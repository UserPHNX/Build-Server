FROM node:18-alpine
WORKDIR /app
COPY . .
EXPOSE 8081
CMD ["node", "server.js"]
