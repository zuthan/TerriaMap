# develop container
FROM node:16 as develop

# build container
FROM node:16 as build
USER node

COPY --chown=node:node . /app

WORKDIR /app

RUN yarn install --network-timeout 1000000
RUN yarn gulp release

# deploy container
FROM node:16-slim as deploy

USER node

WORKDIR /app

# Without the chown when copying directories, wwwroot is owned by root:root.
COPY --from=build --chown=node:node /app/wwwroot wwwroot
COPY --from=build --chown=node:node /app/node_modules node_modules
COPY --from=build /app/serverconfig.json serverconfig.json
COPY --from=build /app/index.js index.js
COPY --from=build /app/package.json package.json
COPY --from=build /app/version.js version.js

EXPOSE ${PORT:-8080}
ENV NODE_ENV=production
CMD [ "node", "./node_modules/terriajs-server/lib/app.js", "--config-file", "serverconfig.json", "--port", "${PORT:-8080}" ]
