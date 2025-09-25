# Usa la imagen base de Nginx
FROM nginx:alpine

# Copia el archivo index.html de la carpeta src a la carpeta por defecto de Nginx
COPY src/index.html /usr/share/nginx/html/index.html

# Nginx corre por defecto en el puerto 80, que coincide con tu definicion de tarea
EXPOSE 80