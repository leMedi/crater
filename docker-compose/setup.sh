#!/bin/sh

docker-compose exec --user=1001 app

docker-compose exec app composer install --no-interaction --prefer-dist --optimize-autoloader

docker-compose exec app php artisan storage:link || true
docker-compose exec app php artisan key:generate
