#!/bin/bash
php artisan swoole:http start &
node watcher.js