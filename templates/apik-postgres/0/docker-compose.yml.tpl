version: '2'
services:
  postgres:
    image: postgres:$strVersion
    labels:
      io.rancher.scheduler.affinity:host_label: nfs=true
    volumes:
      - $strOdooPostgresVolumeName:$strOdooDataPostgres
    environment:
      # Database parameters
      PGDATA: ${strOdooDataPostgres}
      POSTGRES_DB: ${strPgDB}
      POSTGRES_PASSWORD: ${strPgPassword}
      POSTGRES_USER: odoo
      