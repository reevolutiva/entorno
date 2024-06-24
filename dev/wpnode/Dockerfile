# Utiliza la imagen base demyx/openlitespeed
FROM demyx/openlitespeed

# Establece el usuario root para tener permisos de instalación
USER root

# Actualiza el sistema e instala dependencias necesarias
RUN apt-get update && \
    apt-get install -y curl gnupg

# Añade el repositorio de Node.js para la versión específica y lo instala junto con npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs=18.16.0-1nodesource1

# Verifica la instalación de la versión específica de Node.js
RUN node -v && npm -v

# Instala vite globalmente utilizando npm
RUN npm install -g vite@4.5.2

# Limpia el cache de apt para reducir el tamaño de la imagen
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER demyx

# Comando por defecto (puedes ajustarlo según tus necesidades)
CMD ["bash"]
