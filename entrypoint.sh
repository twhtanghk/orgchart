#!/bin/sh

(cd frontend && node_modules/.bin/vue-cli-service build --mode development)
(cd backend && npm start)
