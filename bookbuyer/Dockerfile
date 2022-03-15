FROM node:lts-alpine

ENV NODE_ENV=production
ENV PORT=4000
ENV BOOKSTORE_URL=http://bookstore:3000

WORKDIR /usr/src/app

COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]

RUN npm install --production --silent && mv node_modules ../

COPY . .

EXPOSE 4000

RUN chown -R node /usr/src/app

USER node

CMD ["node", "index.js"]
