#!/bin/sh

pkg=csv-stringify csv-parse stream-transform csv-generate
for i in $pkg; do
  file=frontend/node_modules/$i/lib/es5/index.js
  cp $file $(dirname $file)
done

(cd frontend && npm run build)
(cd backend && npm start)
