version: '2'
services:
  postgres:
    image: postgres:$strVersion
    volumes:
      - $strOdooPostgresVolumeName:$strOdooDataPostgres
    environment:
      # Database parameters
      PGDATA: ${strOdooDataPostgres}
      POSTGRES_DB: ${strPgDB}
      POSTGRES_PASSWORD: ${strPgPassword}
      POSTGRES_USER: odoo
      