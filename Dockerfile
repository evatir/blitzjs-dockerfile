# Install all node_modules and build the project

FROM mhart/alpine-node:16 as builder
WORKDIR /app

# So lib-sodium will compile

RUN apk --update add --no-cache curl git python3 alpine-sdk \
  bash autoconf libtool automake

COPY package.json yarn.lock ./
RUN yarn install --pure-lockfile

COPY . .
RUN yarn blitz prisma format
RUN yarn blitz prisma generate
RUN yarn build

# Copy the above into a slim container

FROM mhart/alpine-node:slim-16
WORKDIR /app

COPY . .
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next

EXPOSE 3000

CMD ["./node_modules/.bin/blitz", "start", "--production"]
