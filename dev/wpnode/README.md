# Docker Container Worpdress + Node JS + Vite 
Este proyecto es un contenedor de Docker que contiene un servidor de Wordpress y un servidor de Node JS con Vite.

## Setup
1. Build the Image
```docker build -t wpnode .```
2. Replace the .env file and docker-compose with the correct values
    El docker-compose.yml tiene que tener el nombre de la imagen que se construyó en el paso anterior.
    El docker compose lleva las configuraciones para levantarlo en una red de trafik, pero esas configuraciones estan desactivadas.
3. Run the containers
    Antes de levantar los contenedores asgurate que las rutas de los volumenes esten correctas y le pertenezcan al usuario 1000.
```docker compose up -d```
4. Dentro de tu plugin o theme configura tu servidor vite de la siguiente manera.
```
import create_config from '@kucrut/vite-for-wp';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default create_config('js/src/main.jsx', 'js/dist', {
	plugins: [react()],
	server: {
		host: "0.0.0.0",
		headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
			'Access-Control-Allow-Private-Network': "*"
        }
		
	}
	
});

```


## Uso

Alerta: Los comando de vite deben correce dentro de l contenedor
``` docker exec -it <contenedor_name> /bin/bash```  

- Vite para compilar
```npm run build```
- Vite para desarrollar
```npm run dev```

Alerta:
- Para hacer correr correctamente el servidor de desarrollo debes tener abierto un tunel ssh en el pueto 5173 de tu maquina con el puerto 5173 del servidor.
- Una vez que el servidor de vite este corriendo, se generara un archivo en la carpeta /dist/vite-dev-server.json.
  Este archivo contiene la configuracion para que el servidor de wordpress pueda servir los archivos de vite.
  Este archivo tendra la siguiente estrctura:
   - ``` {"base":"/","origin":"http://0.0.0.0:5173","port":5173,"plugins":["vite:react-refresh"]} ```
  Debes modificarla de la siguiente manera
   - ``` {"base":"/","origin":"http://localhost:5173","port":5173,"plugins":["vite:react-refresh"]} ```
