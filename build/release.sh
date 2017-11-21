#!/bin/sh
npm run build
npm publish
node build/del.js
