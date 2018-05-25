FROM node

ENV APP=/usr/src/app
ADD . $APP

WORKDIR $APP

RUN npm i -g coffeescript \
&&  (cd backend; yarn install) \
&&  (cd frontend; yarn install)

EXPOSE 1337

ENTRYPOINT ./entrypoint.sh
