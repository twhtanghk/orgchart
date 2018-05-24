FROM node

ENV APP=/usr/src/app
ADD . $APP

WORKDIR $APP

RUN npm i -g coffeescript \
&&  yarn install

EXPOSE 1337

ENTRYPOINT ./entrypoint.sh
