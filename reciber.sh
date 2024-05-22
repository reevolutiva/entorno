#!/bin/bash

# Instanciaar un contenedor docker wp funcional

# Clonar la plantilla del .env
cp .env.template .env

# Clonar la plantilla del docker-compose
cp docker-compose.template.yml docker-compose.yml

# Reemplazar en el .env y en la plantilla de docker-compose
sed -i "s/<my_app>/${1}/g" .env
sed -i "s/<my_domain_app>/${2}/g" .env
sed -i "s/info@<my_domain_app>/${3}/g" .env
sed -i "s/<bd_password>/${4}/g" .env
sed -i "s/<user_bdd>/${5}/g" .env
sed -i "s/<user_wp>/${6}/g" .env
sed -i "s/<wp_user_pass>/${7}/g" .env

sed -i "s/<my_app>/${1}/g" docker-compose.yml
sed -i "s/<my_domain_app>/${2}/g" docker-compose.yml
sed -i "s/info@<my_domain_app>/${3}/g" docker-compose.yml
sed -i "s/<bd_password>/${4}/g" docker-compose.yml
sed -i "s/<user_bdd>/${5}/g" docker-compose.yml
sed -i "s/<user_wp>/${6}/g" docker-compose.yml
sed -i "s/<wp_user_pass>/${7}/g" docker-compose.yml

# Crear una carpeta con el nombre del sitio para almacenar sus volumnes
mkdir ${1}

# Crear carpeta wp
mkdir ${1}/wp

# Crear carpeta db
mkdir ${1}/db

# Crear carpeta log
mkdir ${1}/log

# Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 10001o00
chown -R 1000:1000 ${1}

# Levantamos el docker-compose.yml
docker-compose up -d
