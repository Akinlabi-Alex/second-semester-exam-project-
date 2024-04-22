#!/bin/bash
composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction
#copy the content of the default env file to .env
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache
cd
cd /etc/apache2/sites-available/
sudo touch latest.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/latest.conf
sudo a2ensite latest.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
cd
sudo apt install mysql-server -y
sudo apt install mysql-client -ysudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE siralexdb;"
sudo mysql -uroot -e "CREATE USER 'siralex'@'localhost' IDENTIFIED BY 'vagrant20';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON siralexdb.* TO 'siralex'@'localhost';"

cd /var/www/laravel
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '24 s/=3306/=3306/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=siralexdb/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=siralex/' /var/www/laravel/.env
sudo sed -i '27 s/=/=vagrant20/' /var/www/laravel/.env
sudo php artisan key:generate
sudo php artisan storage:link
sudo php artisan migrate
sudo php artisan db:seed
sudo systemctl restart apache2

