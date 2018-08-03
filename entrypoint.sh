#!/bin/sh

pkg="csv-stringify csv-parse stream-transform csv-generate"
for i in $pkg; do
  dir=frontend/node_modules/$i/lib/es5
  cp $dir/index.js $(dirname $dir)
done

(cd frontend && npm run build)
(cd backend && npm start)
