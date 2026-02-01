```md
# Diseño de Base de Datos - Niufoods Monitor

La base está diseñada para:
- Mantener el **estado actual** de cada dispositivo por restaurante.
- Mantener un **historial** de reportes.
- Mantener un **registro detallado** de mantenciones/actualizaciones por dispositivo.

## Entidades y relaciones
- Un `Restaurant` tiene muchos `Device`.
- Un `Device` tiene muchos `DeviceReport` (historial de estados).
- Un `Device` tiene muchos `MaintenanceLog` (registro de mantenimiento/actualizaciones).

## ERD (Mermaid)

```mermaid
erDiagram
  RESTAURANTS ||--o{ DEVICES : has_many
  DEVICES ||--o{ DEVICE_REPORTS : has_many
  DEVICES ||--o{ MAINTENANCE_LOGS : has_many

  RESTAURANTS {
    bigint id PK
    string name
    string city
    int status "operational|warning|problem"
    datetime created_at
    datetime updated_at
  }

  DEVICES {
    bigint id PK
    bigint restaurant_id FK
    string identifier "unique per restaurant"
    int kind "pos|printer|network|other"
    int status "operational|failing|maintenance|offline"
    datetime last_reported_at
    datetime created_at
    datetime updated_at
  }

  DEVICE_REPORTS {
    bigint id PK
    bigint device_id FK
    int reported_status "operational|failing|maintenance|offline"
    jsonb payload "optional metadata"
    datetime reported_at
    datetime created_at
  }

  MAINTENANCE_LOGS {
    bigint id PK
    bigint device_id FK
    string action "firmware_update|cleaning|..."
    text notes
    datetime started_at
    datetime ended_at
    datetime created_at
    datetime updated_at
  }