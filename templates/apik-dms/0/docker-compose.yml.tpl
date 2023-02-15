version: '2'

volumes:
  datamayan:
  datapg:
    
services:
  mayan-dms:
    image: mayanedms/mayanedms:s4.3
    environment:
      MAYAN_CELERY_BROKER_URL: redis
      MAYAN_CELERY_RESULT_BACKEND: redis
      MAYAN_DATABASES: "{'default':{'ENGINE':'django.db.backends.postgresql','NAME':'mayan','PASSWORD':${mayanuserpass},'USER':'mayan','HOST':'postgres'}}"
      MAYAN_LOCK_MANAGER_BACKEND: "mayan.apps.lock_manager.backends.redis_lock.RedisLock"
      MAYAN_LOCK_MANAGER_BACKEND_ARGUMENTS: {'redis_url':'redis'}
    volumes:
      - datamayan: /var/lib/mayan
    labels:
      traefik.enable: true
      traefik.port: 8000
      traefik.frontend.rule: Host:${HostDMS}
      io.rancher.scheduler.affinity:host_label_ne: ${labelDMS}=true
    depends_on:
      - redis
      - postgres
      
  postgres:
    image: postgres:13.8-alpine
    environment:
      POSTGRES_USER:${PgUSER}
      POSTGRES_DB:${PgDB}
      POSTGRES_PASSWORD:${PgPASSWORD}
    volumes:
      - datapg:/var/lib/postgresql/data/pgdata
    labels:
      io.rancher.scheduler.affinity:host_label_ne: ${labelDMS}=true
      
  redis:
    image: redis:7.0.5-alpine
    ports:
      - '6379'
    labels:
      io.rancher.scheduler.affinity:host_label_ne: ${labelDMS}=true
    command:
      - redis-server
      - --databases
      - "3"
      - --maxmemory-policy
      - allkeys-lru
      - --save
      - ""