#!/usr/bin/env sh

# abort on errors
set -e

# build
npm run build
cd dist

# set custom domain
echo enchantedshulkers.rubixdev.de > CNAME

# deploy
git init -b master
git add -A
git commit -m 'deploy'
git push -f git@github.com:RubixDev/enchantedshulkers-pack-patcher.git master:deploy

cd -
