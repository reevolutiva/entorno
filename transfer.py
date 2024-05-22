

# Extraer de SERVER ORIGIN wp-content y convertirloa un .zip

## Preguntar al usuario la ruta del wordpress que se quiere extraer

## Revisar si es wordpress vanilla o bedrock

### Si es wordpress vanilla (wp-content en la raiz) -> Comprimir wp-content en un .zip
### Si es wordpress bedrock (wp-content en la carpeta web) -> Comprimir web/wp-content en un .zip

# Extraers SERVER ORIGING una copia de la BDD (mysqldump)

## Extraer de wp-config el nombre de BDD, usuario y contraseña.
## Hacer una copia de la BDD usando mysqldump en formato sql.

# Enviar por scp multihilo optimizado con comprovacion de falla los archivos .zip y .sql a SERVER DESTINO
## el .zip debe quedar en /volumen/wp/
## el .sql debe quedar en /volumen/db/


