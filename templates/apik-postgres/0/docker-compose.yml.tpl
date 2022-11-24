version: '2'
services:
  postgres-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
      - pgdata:/var/lib/postgresql/data/pgdata
      
  postgres:
    image: postgres:$strVersion
    labels:
      io.rancher.scheduler.affinity:host_label: pg_rancher=true
      io.rancher.sidekicks: postgres-data
    volumes_from:
      - postgres-data
    environment:
      # Database parameters
      PGDATA: ${strOdooDataPostgres}
      POSTGRES_DB: ${strPgDB}
      POSTGRES_PASSWORD: ${strPgPassword}
      POSTGRES_USER: odoo

volumes:
  $strOdooPostgresVolumeName:
    driver: rancher-nfs
    per_container: true
