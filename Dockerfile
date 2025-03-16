# ===== Etapa Base =====
ARG BASE=node:20
FROM ${BASE} AS base

# Instalar Git (necesario para algunas dependencias)
RUN apt-get update && apt-get install -y git

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias (esto se cachea mientras no cambien)
COPY package.json pnpm-lock.yaml ./

# Instalar PNPM y las dependencias de la aplicación
RUN npm install -g pnpm && pnpm install

# Copiar el resto del código de la aplicación
COPY . .

# Exponer el puerto en el que la aplicación escucha (ajústalo si es necesario)
EXPOSE 5173

# ===== Etapa de Producción =====
# Esta etapa se usará como imagen final para desplegar en producción.
FROM base AS final

# (Opcional) Si no usas Cloudflare, puedes eliminar o comentar estas líneas:
# RUN mkdir -p /root/.config/.wrangler && \
#     echo '{"enabled":false}' > /root/.config/.wrangler/metrics.json

# Ejecutar el proceso de build (compilación/optimización de la app)
RUN pnpm run build

# Comando final para arrancar la aplicación en producción.
# Asegúrate de que en package.json exista un script llamado "dockerstart" 
# (por ejemplo, "dockerstart": "node server.js" o similar).
CMD ["pnpm", "run", "dockerstart"]
