#!/bin/sh

set -u
set -e

chmod -R 777 storage bootstrap/cache

if [ ! -d node_modules ]; then
  mkdir -p ~/node_modules
  ln -snf ~/node_modules node_modules
fi

curl https://getcomposer.org/installer > composer-installer
php composer-installer

# dummy user, no privilege github token to avoid github api limit
php composer.phar config -g github-oauth.github.com 98cbc568911ef1e060a3a31623f2c80c1786d5ff

php composer.phar install

php artisan migrate --force
php artisan lang:js resources/assets/js/messages.js

npm install
./node_modules/bower/bin/bower install --allow-root
./node_modules/gulp/bin/gulp.js --production
