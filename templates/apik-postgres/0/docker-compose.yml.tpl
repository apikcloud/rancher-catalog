version: '2'
services:
      
  postgres:
    image: postgres:$strVersion
    labels:
      io.rancher.scheduler.affinity:host_label: pg_rancher=true
    volumes:
      - odoo_data_postgres:/${strOdooDataPostgres}
    environment:
      # Database parameters
      PGDATA: ${strOdooDataPostgres}
      POSTGRES_DB: ${strPgDB}
      POSTGRES_PASSWORD: ${strPgPassword}
      POSTGRES_USER: odoo

volumes:
  odoo_data_postgres:
    driver: rancher-nfs
    per_container: true
    external: true