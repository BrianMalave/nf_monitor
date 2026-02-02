## Niufoods Monitor

este proyecto como prueba, respresenta un sistema centralizado de monitoreo para una franquicia de restaurantes, donde se reporta el estado de los dispositivos(POS, impresoras, red) que posee cada local a traves de una api general desarrollada en Ruby on Rails.

- Arquitectura (diagrama): `docs/architecture.md`
- Base de datos (ERD): `docs/database.md`

El sistema realiza las siguientes tareas:

- Recepción de reportes periodicos de los restaurantes
- Procesamiento de datos synch o async mediante Sidekiq
- Historial y estado en PostgreSQL
- Visualización de la información en tiempo real a traves de un dashboard hecho en React.

## Flujo de datos:
    A[Restaurante / Script Simulador] --> |HTTP JSON| B[Rails API]
    B --> |queue| 	   C[Sidekiq]
    C --> |processing| D[PostgresSQL]
    D --> |query|	   E[REST api]
    E --> |fetch|	   F[React Dashboard]

## Componentes
- Backend: Ruby on Rails 8
- DB: PostgreSQL
- Jobs: Sidekiq + Redis (Docker/WSL)
- Frontend: ReactJS + Vite
- Simulación: Script Ruby independiente

## Diseño de base de datos y modelos:

- Restaurants model
  * id
  * name
  * city
  * status (operational, warning, problem)

- Devices model
  * identifier
  * kind (pos, printer, network)
  * status (operational, failing, maintenance, offline)
  * restaurant_id

- DeviceReports model
  * device_id
  * reported_status
  * reported_at
  * payload (jsonb)

- MaintenanceLogs model
  * device_id
  * action
  * notes
  * started_at
  * ended_at

## Endpoints Principales (API)

- Creación de reporte de dispositivos
  POST /api/v1/device_reports

- Payload de ejemplo:
  JSON
  {
    "report": {
      "restaurant": {
        "name": "Niu Centro",
        "city": "Santiago"
      },
      "devices": [
        {
          "identifier": "POS-1",
          "kind": "pos",
          "status": "operational",
          "meta": { "ip": "10.0.0.2" }
        }
      ]
    }
  }

- Respuesta de payload:
  JSON
  { "ok": true, "queued": true }

- Listado de restaurantes(para dashboard)
  GET /api/v1/restaurants

- Detalle de un restaurante
  GET /api/v1/restaurants/:id

## Procesamiento en Segundo plano por Sidekiq
Los reportes son procesados a traves de sidekiq mediante Redis-server en ejecución via Docker que se encarga de:
- Crear o actualizar restaurantes
- Actualizar estado de dispositivos
- Registrar historia(device_reports)
- Registrar mantenimientos(maintenance_logs)
- Recalcular el estado general del restaurante

## Script de Simulación de restaurantes:
 ruta: scripts/restaurant_simulator.rb

- Simula multiples restaurantes
- Genera estados de dispositivos de forma aleatoria
- Envia reportes cada 5 segundos a la API
- Permite observar cambios en tiempo real para el dashboard

## Ejecución de Script
  ruby scripts/restaurant_simulator.rb

## Frontend - React Dashboard
Para finalidades de la prueba se realizó con ReactJS, donde consta de las siguientes funcionalidades:

- Lista de restaurantes con estado general
- Colores por estado(operational / stand_by, stopped)
- Polling automatico cada 5 segundos
- Vista de detalle por restaurantes
- Estado de dispositivos con colores
- Navegación con React Router

Tanto la aplicación backend de ruby y el frontend en react, estan alojados en el mismo repositorio carpeta raiz llamada niufoods_monitor


- Server frontend: http://localhost:5173

## Ejecución de proyecto completo a traves de comandos:

1. Backend y servidores de Rails
  - bundle install
  - bundle exec rails db:create db:migrate
  - bundle exec rails s

2. Redis + Sidekiq
  - docker ps
  - docker run -d -p 6379:6379 --name redis7 redis:7
  - bundle exec sidekiq
    * IMPORTANTE: Verificar siempre que el servidor de redis-server este activo, a traves de Docker Desktop o los comandos proporcionados para que el job de sidekiq pueda realizar su proceso correctamente

3. Frontend(React Dashboard)
Desde la carpeta raiz:
  - cd frontend
  - npm install
  - npm run dev

4. Simulación
  - ruby scripts/restaurant_simulator.rb

Notas finales:
- Uno de los enfoques de este proyecto fue separar responsabilidades entre el backend, jobs, la simulación y el frontend.
- Se realizó el dashboard con ReactJS para mayor rapidez de proceso de desarrollo.
- Para fines de la prueba, se realizo en Ruby puro, además de aumentar ligeramente la probabilidad del estado :operational
- Verificar siempre el correcto funcionamiento de Redis y de Sidekiq para que los workers muestren los datos correctamente en tiempo real.

Ha sido todo un desafio la creación y levantamiento de este proyecto como prueba para Ruby on Rails. Personalmente me he divertido bastante y agradezco a todo el equipo de Niufoods por la oportunidad de realizar esta aplicación.