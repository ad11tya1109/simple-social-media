#!/bin/sh
set -e

# Buat direktori yang diperlukan
mkdir -p bootstrap/cache \
         storage/framework/cache \
         storage/framework/sessions \
         storage/framework/views

# Atur permission
chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

# Install library frontend
npm install --legacy-peer-deps --no-audit --progress=false
npm run dev

# --- PERBAIKAN DI SINI ---
# Menambah timeout menjadi 2000 detik (sekitar 33 menit) agar tidak error saat download package berat
COMPOSER_PROCESS_TIMEOUT=2000 composer install --optimize-autoloader
# -------------------------

# Setup environment file
cp .env.example .env || true
php artisan key:generate

# Konfigurasi database di .env
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' .env

# Jalankan migrasi jika diperlukan
# php artisan migrate --force
# php artisan db:seed --force
