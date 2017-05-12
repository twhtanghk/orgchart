FROM node

ENV VER=${VER:-master} \
    REPO=https://github.com/ewnchui/orgchart \
    APP=/usr/src/app

WORKDIR $APP

RUN git clone -b $VER $REPO $APP \
&&  npm install \
&&  node_modules/.bin/bower install --allow-root
	

EXPOSE 1337

ENTRYPOINT ./entrypoint.sh
