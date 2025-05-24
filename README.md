# comunity-ini

Esta carpeta contiene configuraciones y scripts para la administración de servicios relacionados con redes sociales, analítica y automatización. A continuación, se describen los archivos y servicios incluidos:

## Archivos principales
- **`docker-compose.yml`**: Archivo de configuración para levantar múltiples servicios con Docker. Incluye:
  - **Jupyter**: Para scraping y análisis SEO.
  - **N8N**: Automatización de publicaciones en redes sociales.
  - **Metabase**: Visualización de datos.
  - **Grafana**: Monitoreo de métricas.
  - **Prometheus**: Recolección de métricas.
  - **Matomo**: Analítica web.
  - **Plausible**: Alternativa ligera a Google Analytics.
  - **Rasa**: Chatbot avanzado.

- **`init-config.sh`**: Script de configuración inicial que:
  - Detecta el sistema operativo (Linux o Windows).
  - Instala dependencias necesarias como Docker, Git, y otros.
  - Crea archivos de configuración predeterminados para Prometheus, Plausible y NTFY si no existen.

## Servicios configurados
- **Jupyter**: Para análisis y scraping.
- **N8N**: Automatización de flujos de trabajo.
- **Metabase**: Herramienta de inteligencia de negocios.
- **Grafana**: Visualización de métricas.
- **Prometheus**: Monitoreo y alertas.
- **Matomo**: Analítica web.
- **Plausible**: Analítica ligera.
- **Rasa**: Chatbot con IA.

## Requisitos
- En Windows, ajustar las rutas en `init-config.sh`.
- Tener instalado `git bash` o WSL en ejecución.