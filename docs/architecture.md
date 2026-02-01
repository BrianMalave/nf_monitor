# Arquitectura (alto nivel) - Niufoods Monitor

Este app permite que cada restaurante envíe regularment el estado de sus dispositivos a una API central.
La API encola el procesamiento en segundo plano (Sidekiq) para guardar historial y actualizar el estado general.

## Flujo de datos (Sidekiq - alto nivel)

```mermaid
flowchart LR
  R[Restaurante\nScript Ruby simulador] -->|HTTP POST /api/v1/device_reports| API[Rails API\nController]
  API -->|Encola Job| Q[(Redis / Sidekiq Queue)]
  API -->|202 Accepted| R

  Q --> W[Sidekiq Worker\nProcesa Reporte]
  W --> DB[(PostgreSQL)]
  DB --> W

  subgraph DBTables[Tablas]
    DB --> T1[restaurants]
    DB --> T2[devices]
    DB --> T3[device_reports\n(historial)]
    DB --> T4[maintenance_logs\n(mantenciones)]
  end