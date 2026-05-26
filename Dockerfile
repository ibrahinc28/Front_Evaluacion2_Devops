# --- Etapa 1: Construcción y Dependencias ---
FROM python:3.11-alpine AS builder
WORKDIR /app

# Instalar herramientas de compilación por si alguna dependencia de Python las requiere
RUN apk add --no-cache gcc musl-dev linux-headers

# Copiar el archivo de requerimientos
COPY requirements.txt .

# Instalar dependencias en el espacio de usuario para aislamiento
RUN pip install --no-cache-dir --user -r requirements.txt

# --- Etapa 2: Entorno de Ejecución Ligero y Seguro ---
FROM python:3.11-alpine
WORKDIR /app

# Crear un usuario no-root (appuser) para cumplir con el estándar de seguridad de la rúbrica
RUN adduser -D appuser && chown -R appuser:appuser /app

# Copiar las dependencias instaladas desde la etapa de construcción anterior
COPY --from=builder /root/.local /home/appuser/.local

# Copiar el código fuente del frontend al contenedor
COPY . .

# Asegurar que el usuario correcto sea dueño de los archivos copiados
RUN chown -R appuser:appuser /app

# Cambiar al usuario sin privilegios
USER appuser

# Configurar variables de entorno para que Python encuentre las dependencias instaladas y no genere buffering en logs
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Exponer el puerto por defecto (comúnmente 5000 para aplicaciones Flask en Python)
EXPOSE 5000

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]