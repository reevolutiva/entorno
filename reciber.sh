# Intanciaar un contenedor docker wp funcional
## Clonar la plantilla del .env
## Clonar la plantilla del docker-compose
## Reemplazar en el .env y en la plantillade docker-compose
### Reemplace <my_app> por el nombre de su app.
### Reemplace <my_domain_app> por el dominio de su app
### Reemplace info@<my_domain_app> un correo electrónico real.
### Reemplace <bd_password> una contraseña real.
### Reemplace <user_bdd> un nombre de usuario para BDD.
### Reemplace <user_wp>un nombre de usuario para Wordpress.
### Reemplace <wp_user_pass> una contraseña real.
## Crear una carpeta con el nombre del sitio para almacenar sus volumnes
### Crear carpeta wp
### Creare carpeta db
### Crear carpeta log

## Cambiamos el owner de la carpeta y todas su subcarpetas por el usuario 1000
## Levantamos el docker-compose.yml

# Migracion de un sitio de wordpress
## SI el wp bedrock
## Eliminamos la carpeta web
## Entonces
## Eliminamos la carpeta wp-content

## Copiamos el archivo .zip a la carpeta wp
## Copiamos el archivo .sql a la carpeta db

## Descomprimimos el .zip en la carpeta wp
## Cambiamos los permisos de todos los ficheros dentro de la carpeta wp

## Entramos a la terminal del contenedor mysql.
## Entramos a mysql.
## Creamos una BDD vacia con el mismo nombre que la original.
## Entramos en la BDD.
## Importamos el .sql con SOURCE
## Le damos los permisos al usuario de la BDD
## Cambiamos el nombre de la BDD en wp-config.php

