#!/bin/sh

(cd frontend && npm run build)
(cd backend && npm start)
