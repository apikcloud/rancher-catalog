version: '2'
services:
      
  postgres:
    image: postgres:$strVersion
    labels:
      io.rancher.scheduler.affinity:host_label: ${strNodeExecution}
    volumes:
      - data:${strOdooDataPostgres}
    environment:
      # Database parameters
      PGDATA: ${strOdooDataPostgres}
      POSTGRES_DB: ${strPgDB}
      POSTGRES_PASSWORD: ${strPgPassword}
      POSTGRES_USER: odoo

volumes:
  data:
    driver: rancher-nfs
    
