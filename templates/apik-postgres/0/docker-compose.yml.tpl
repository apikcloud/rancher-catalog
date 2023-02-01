version: '2'
services:
      
  postgres:
    image: postgres:$strVersion
    labels:
      io.rancher.scheduler.affinity:host_label_soft: ${host_label}
      io.rancher.scheduler.affinity:host_label_ne: ${dedie_label}
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
    
