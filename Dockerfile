FROM node:24-alpine AS builder

RUN apk add --no-cache git
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /usr/src/app
ENV PATH="/usr/src/app/node_modules/.bin:$PATH"

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build

FROM node:24-alpine AS runtime

ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY package.json ./

EXPOSE 3001

CMD ["node", "dist/main.js"]
