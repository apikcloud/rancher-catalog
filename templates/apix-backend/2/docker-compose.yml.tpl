version: '2'
services:

  redis:
    image: redis:6-alpine
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}

  api:
    image: apik/apix-backend:${strVersion}
    ports:
      - 8008:8000
    command: /start
    environment:
      - PROJECT_NAME=ApiX backend
      - MODE=${enumMode}
      - WORKERS=${intWorkers}
      - api_key=${strApiKey}
      - APP_DIR=${strAppDir}
      - OUTPUT_DIR=/usr/src/output
      - INPUT_DIR=/usr/src/input
      - FILESTORE_PATH=/usr/src/filestore
      - DEPLOYMENTS_PATH=data/deployments
      - FLOWER_BASIC_AUTH=${strFlowerAuth}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - RANCHER_ENVIRONMENT=${strRancherEnv}
      - PROMETHEUS_URL=${strPrometheusUrl}
      - SERVICES=${multiServices}
      - STORAGE_PROVIDERS=${multiStorageProviders}
      - DEFAULT_STORAGE_PROVIDER=${strDefaultStorageProvider}
      - POSTGRESQL_SERVERS=${multiPostgresqlServers}
    volumes:
      - backend-input:/usr/src/input
      - backend-output:/usr/src/output
      - $strFilestoreVolumeName:/usr/src/filestore
      - backend-conf:/usr/src/conf
    depends_on:
      - redis
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
      traefik.enable: 'true'
      traefik.port: '8000'
      traefik.frontend.rule: Host:${strApiUrl}
      traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
      traefik.backend.loadbalancer.method: drr
      traefik.backend.loadbalancer.stickiness: 'true'

  worker:
    image: apik/apix-backend:${strVersion}
    command: /start-celeryworker
    environment:
      - PROJECT_NAME=ApiX backend
      - MODE=${enumMode}
      - WORKERS=${intWorkers}
      - api_key=${strApiKey}
      - APP_DIR=${strAppDir}
      - OUTPUT_DIR=/usr/src/output
      - INPUT_DIR=/usr/src/input
      - FILESTORE_PATH=/usr/src/filestore
      - DEPLOYMENTS_PATH=data/deployments
      - FLOWER_BASIC_AUTH=${strFlowerAuth}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - RANCHER_ENVIRONMENT=${strRancherEnv}
      - PROMETHEUS_URL=${strPrometheusUrl}
      - SERVICES=${multiServices}
      - STORAGE_PROVIDERS=${multiStorageProviders}
      - DEFAULT_STORAGE_PROVIDER=${strDefaultStorageProvider}
      - POSTGRESQL_SERVERS=${multiPostgresqlServers}
    volumes:
      - backend-input:/usr/src/input
      - backend-output:/usr/src/output
      - $strFilestoreVolumeName:/usr/src/filestore
      - backend-conf:/usr/src/conf
    depends_on:
      - api
      - redis
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}

  celery_beat:
    image: apik/apix-backend:${strVersion}
    command: /start-celerybeat
    environment:
      - PROJECT_NAME=ApiX backend
      - MODE=${enumMode}
      - WORKERS=${intWorkers}
      - api_key=${strApiKey}
      - APP_DIR=${strAppDir}
      - OUTPUT_DIR=/usr/src/output
      - INPUT_DIR=/usr/src/input
      - FILESTORE_PATH=/usr/src/filestore
      - DEPLOYMENTS_PATH=data/deployments
      - FLOWER_BASIC_AUTH=${strFlowerAuth}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - RANCHER_ENVIRONMENT=${strRancherEnv}
      - PROMETHEUS_URL=${strPrometheusUrl}
      - SERVICES=${multiServices}
      - STORAGE_PROVIDERS=${multiStorageProviders}
      - DEFAULT_STORAGE_PROVIDER=${strDefaultStorageProvider}
      - POSTGRESQL_SERVERS=${multiPostgresqlServers}
    depends_on:
      - redis
      - api
      - worker
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}

  flower:
    image: apik/apix-backend:${strVersion}
    command: /start-flower
    environment:
      - PROJECT_NAME=ApiX backend
      - MODE=${enumMode}
      - WORKERS=${intWorkers}
      - api_key=${strApiKey}
      - APP_DIR=${strAppDir}
      - OUTPUT_DIR=/usr/src/output
      - INPUT_DIR=/usr/src/input
      - FILESTORE_PATH=/usr/src/filestore
      - DEPLOYMENTS_PATH=data/deployments
      - FLOWER_BASIC_AUTH=${strFlowerAuth}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - RANCHER_ENVIRONMENT=${strRancherEnv}
      - PROMETHEUS_URL=${strPrometheusUrl}
      - SERVICES=${multiServices}
      - STORAGE_PROVIDERS=${multiStorageProviders}
      - DEFAULT_STORAGE_PROVIDER=${strDefaultStorageProvider}
      - POSTGRESQL_SERVERS=${multiPostgresqlServers}
    ports:
      - 5555:5555
    depends_on:
      - redis
      - api
      - worker
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
      traefik.frontend.rule: Host:${strFlowerUrl}
      traefik.enable: 'true'
      traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
      traefik.backend.loadbalancer.method: drr
      traefik.backend.loadbalancer.stickiness: 'true'
      traefik.port: '5555'


volumes:
  backend-input:
    driver: rancher-nfs
    external: true
  backend-output:
    driver: rancher-nfs
    external: true
  backend-conf:
    driver: rancher-nfs
    external: true
  $strFilestoreVolumeName:
    driver: rancher-nfs
    external: true