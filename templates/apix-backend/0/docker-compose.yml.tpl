version: '2'
services:

  redis:
    image: redis:6-alpine
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}

  api:
    image: apik/apix-backend:${strVersion}
    command: start_api
    environment:
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - GOOGLE_DEFAULT_BUCKET=${strGoogleDefaultBucket}
      - APP_DIR=${strAppDir}
      - GIT_URL=${strGitUrl}
    volumes:
      - backend-app:${strAppDir}
      - backend-data-input:/usr/src/input
      - backend-data-output:/usr/src/output
      - backend-data-filestore:/usr/src/filestore
    depends_on:
      - redis
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
      traefik.enable: 'true'
      traefik.port: '8000'
      traefik.frontend.rule: Host:backend-api.apik.cloud
      traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
      traefik.backend.loadbalancer.method: drr
      traefik.backend.loadbalancer.stickiness: 'true'

  worker:
    image: apik/apix-backend:${strVersion}
    command: start_worker
    volumes:
      - backend-app:${strAppDir}
      - backend-data-input:/usr/src/input
      - backend-data-output:/usr/src/output
      - backend-data-filestore:/usr/src/filestore
    environment:
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
      - RANCHER_SECRET_KEY=${strRancherSecretKey}
      - RANCHER_ACCESS_KEY=${strRancherAccessKey}
      - RANCHER_URL=${strRancherUrl}
      - GOOGLE_DEFAULT_BUCKET=${strGoogleDefaultBucket}
    depends_on:
      - api
      - redis
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}

  flower:
    image: mher/flower:0.9.7
    command: ['flower', '--broker=redis://redis:6379', '--port=5555']
    ports:
      - 5555:5555
    depends_on:
      - api
      - redis
      - worker
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
      traefik.frontend.rule: Host:backend-flower.apik.cloud
      traefik.enable: 'true'
      traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
      traefik.backend.loadbalancer.method: drr
      traefik.backend.loadbalancer.stickiness: 'true'
      traefik.port: '5555'

  notebook:
    image: apik/notebook-git:${strNotebookVersion}
    ports:
      - 8888:8888
    user: root
    depends_on:
      - api
      - redis
      - worker
    environment:
      - JUPYTER_TOKEN=${strNotebookToken}
      - JUPYTER_ENABLE_LAB=yes
      - GIT_USERNAME=${strGitUsername}
      - GIT_EMAIL=${strGitEmail}
      - NB_GID=999
      - NB_IUD=1000
    volumes:
      - backend-app:/home/jovyan/app
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
      traefik.frontend.rule: Host:backend-notebook.apik.cloud
      traefik.enable: 'true'
      traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
      traefik.backend.loadbalancer.method: drr
      traefik.backend.loadbalancer.stickiness: 'true'
      traefik.port: '8888'

volumes:
  backend-app:
  backend-data-input:
  backend-data-output:
  backend-data-filestore: