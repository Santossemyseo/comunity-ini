# comunity-ini

Plataforma local de **automatización + analítica + observabilidad** basada en Docker Compose.

## Qué hace este repositorio
Este proyecto levanta un entorno integrado para:
- Automatizar flujos (n8n).
- Analizar comportamiento y tráfico (Matomo / Plausible / Metabase).
- Monitorizar salud y métricas (Prometheus / Grafana).
- Ejecutar análisis en notebooks (Jupyter).

## Archivos principales (con su propósito)
- `docker-compose.yml`: orquestación de servicios y sus dependencias.
- `init-config.sh`: bootstrap para generar configs mínimas y, opcionalmente, instalar dependencias.
- `prometheus/prometheus.yml`: configuración de scrape de Prometheus.
- `plausible/plausible-config.env`: variables de entorno de Plausible y sus DB.
- `ntfy/config.yml`: configuración básica para notificaciones push (si decides activar el servicio ntfy).

## Interrelaciones (mapa funcional)
1. **Prometheus** recolecta métricas del stack.
2. **Grafana** consume métricas de Prometheus para paneles y alertas.
3. **Plausible** depende de **PostgreSQL** (`plausible-db`) y **ClickHouse** (`plausible-events-db`).
4. **Metabase** usa su SQLite local para BI y puede conectarse a otras fuentes.
5. **n8n** puede orquestar flujos con datos de Matomo/Plausible/Grafana y disparar acciones.
6. **Jupyter** permite análisis ad-hoc y prototipos sobre datos exportados.

## Levantar el entorno
```bash
chmod +x init-config.sh
./init-config.sh
# opcional: ./init-config.sh --install-deps

docker compose up -d
```

## Validación rápida
```bash
docker compose config
```
Si este comando no muestra errores, la orquestación es válida.

## URLs locales
- Jupyter: http://localhost:8888
- n8n: http://localhost:5678
- Metabase: http://localhost:3000
- Grafana: http://localhost:4000
- Prometheus: http://localhost:9090
- Matomo: http://localhost:8080
- Plausible: http://localhost:8000

## Casos de uso prácticos
1. **Marketing de contenidos**
   - n8n publica en redes según calendario.
   - Matomo/Plausible miden conversiones por canal.
   - Metabase construye reportes semanales para negocio.

2. **Operación de comunidad digital**
   - Prometheus + Grafana alertan sobre caídas o latencia.
   - n8n notifica al equipo cuando hay incidentes.

3. **Experimentación y growth**
   - Jupyter analiza cohorts o retención.
   - Plausible compara campañas A/B.
   - Metabase centraliza resultados para decisiones.

## Notas
- Cambia `SECRET_KEY_BASE` en `plausible/plausible-config.env` por un valor seguro en entornos reales.
- Las credenciales por defecto de n8n son solo para entorno local de pruebas.
