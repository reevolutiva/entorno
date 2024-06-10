import os
def buscar_archivo_env(ruta, key, toReplace):
    # Recorre todos los directorios y archivos dentro de la ruta especificada
    for root, dirs, files in os.walk(ruta):
        for file in files:
            # Verifica si el archivo tiene la extensión .env
            if file.endswith(".env"):
                # Obtiene la ruta completa del archivo
                archivo = os.path.join(root, file)
                # Abre el archivo en modo lectura
                with open(archivo, 'r') as f:
                    # Lee todas las líneas del archivo
                    lines = f.readlines()
                # Abre el archivo en modo escritura
                with open(archivo, 'w') as f:
                    # Recorre cada línea del archivo
                    for line in lines:
                        # Verifica si la línea contiene la clave a reemplazar
                        if key in line:
                            # Reemplaza la clave por el valor especificado
                            line_parts = line.split("=")
                            print(line)
                            print(line_parts)
                            if len(line_parts) > 1:
                                line_parts[1] = toReplace
                                print(line_parts);
                            line = "=".join(line_parts)
                        # Escribe la línea en el archivo
                        f.write(line)
                # Imprime la ruta del archivo .env encontrado
                print(f"Archivo .env encontrado: {archivo}")
                # Retorna la ruta del archivo encontrado
                return archivo
    
    # Si no se encuentra ningún archivo .env en la ruta
    print("No se encontró ningún archivo .env en la ruta especificada.")
    return None
