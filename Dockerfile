
FROM python:3.11-alpine AS builder
WORKDIR /app


RUN apk add --no-cache gcc musl-dev linux-headers


COPY requirements.txt .


RUN pip install --no-cache-dir --user -r requirements.txt


FROM python:3.11-alpine
WORKDIR /app


RUN adduser -D appuser && chown -R appuser:appuser /app


COPY --from=builder /root/.local /home/appuser/.local


COPY . .


RUN chown -R appuser:appuser /app


USER appuser


ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1


EXPOSE 5000


CMD ["python", "app.py"]