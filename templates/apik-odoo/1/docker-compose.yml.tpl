version: '2'
services:
    odoo:
        tty: true
        stdin_open: true
        image: $strImageName:$strImageTag
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.scheduler.affinity:host_label: ${host_label}
            traefik.enable: true
            traefik.port: 8069
            traefik.backend.loadbalancer.stickiness: true
            traefik.backend.loadbalancer.method: drr
            traefik.backend.buffering.retryExpression: IsNetworkError() && Attempts() < 5
        {{- if ne .Values.strGCECloudsqlConnectionName "" }}
            io.rancher.sidekicks: gce-psql-proxy
        {{- end}}
        {{- if eq .Values.intWorkers "0"}}
            traefik.frontend.rule: Host:$strTraefikDomains
            traefik.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.frontend.redirect.permanent: true
        {{- if gt .Values.intDomains "1"}}
            ${"traefik."+strTraefikDomains2+".frontend.rule:"} Host:$strTraefikDomains2
        {{- end}}
        {{- if gt .Values.intDomains "2"}}    
            ${"traefik." + strTraefikDomains3 + ".frontend.rule:"} Host:$strTraefikDomains3
        {{- end}}
        {{- if gt .Values.intDomains "3"}}    
            ${"traefik." + strTraefikDomains4 + ".frontend.rule:"} Host:$strTraefikDomains4
        {{- end}}
        {{- if gt .Values.intDomains "4"}}    
            ${"traefik." + strTraefikDomains5 + ".frontend.rule:"} Host:$strTraefikDomains5
        {{- end}}
        {{- else}}
            traefik.odoo.port: 8069
            traefik.odoo.frontend.rule: Host:$strTraefikDomains
            traefik.odoo.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.odoo.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.odoo.frontend.redirect.permanent: true
            traefik.longpolling.port: 8072
            traefik.longpolling.frontend.rule: Host:$strTraefikDomains;PathPrefix:/longpolling/
            traefik.longpolling.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.longpolling.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.longpolling.frontend.redirect.permanent: true
        {{- if gt .Values.intDomains "1"}}
            ${"traefik.odoo." + strTraefikDomains2 + ".frontend.rule:"} Host:$strTraefikDomains2
            ${"traefik.longpolling." + strTraefikDomains2 + ".frontend.rule:"} Host:$strTraefikDomains2;PathPrefix:/longpolling/
            ${"traefik.longpolling." + strTraefikDomains2 + ".frontend.redirect.regex:"} $strTraefikRedirectRegex2
            ${"traefik.longpolling." + strTraefikDomains2 + ".frontend.redirect.replacement:"} $strTraefikRedirectReplacement2
            ${"traefik.longpolling." + strTraefikDomains2 + ".frontend.redirect.permanent:"} true
        {{- end}}
        {{- if gt .Values.intDomains "2"}}
            ${"traefik.odoo." + strTraefikDomains3 + ".frontend.rule:"} Host:$strTraefikDomains3
            ${"traefik.longpolling." + strTraefikDomains3 + ".frontend.rule:"} Host:$strTraefikDomains3;PathPrefix:/longpolling/
            ${"traefik.longpolling." + strTraefikDomains3 + ".frontend.redirect.regex:"} $strTraefikRedirectRegex3
            ${"traefik.longpolling." + strTraefikDomains3 + ".frontend.redirect.replacement:"} $strTraefikRedirectReplacement3
            ${"traefik.longpolling." + strTraefikDomains3 + ".frontend.redirect.permanent:"} true
        {{- end}}
        {{- if gt .Values.intDomains "3"}}   
            ${"traefik.odoo." + strTraefikDomains4 + ".frontend.rule:"} Host:$strTraefikDomains4 
            ${"traefik.longpolling." + strTraefikDomains4 + ".frontend.rule:"} Host:$strTraefikDomains4;PathPrefix:/longpolling/
            ${"traefik.longpolling." + strTraefikDomains4 + ".frontend.redirect.regex:"} $strTraefikRedirectRegex4
            ${"traefik.longpolling." + strTraefikDomains4 + ".frontend,redirect.replacement:"} $strTraefikRedirectReplacement4
            ${"traefik.longpolling." + strTraefikDomains4 + ".frontend.redirect.permanent:"} true
        {{- end}}
        {{- if gt .Values.intDomains "4"}} 
            ${"traefik.odoo." + strTraefikDomains5 + ".frontend.rule:"} Host:$strTraefikDomains5
            ${"traefik.longpolling." + strTraefikDomains5 + ".frontend.rule:"} Host:$strTraefikDomains5;PathPrefix:/longpolling/
            ${"traefik.longpolling." + strTraefikDomains5 + ".frontend.redirect.regex:"} $strTraefikRedirectRegex5
            ${"traefik.longpolling." + strTraefikDomains5 + ".frontend.redirect.replacement:"} $strTraefikRedirectReplacement5
            ${"traefik.longpolling." + strTraefikDomains5 + ".frontend.redirect.permanent:"} true
        {{- end}}
        {{- end}}

        volumes:
            - $strOdooFilestoreVolumeName:$strOdooDataFilestore
        {{- if eq .Values.enumSessionsStore "filestore" }}
            - $strOdooSessionsVolumeName:$strOdooDataSessions
        {{- end}}

        environment:
            # Database parameters
            PGUSER: ${strPgUser}
            PGPASSWORD: ${strPgPassword}
            PGHOST: ${strPgHost}
            PGPORT: ${strPgPort}
            PGDATABASE: ${strDatabase}
            DATABASE: ${strDatabase}
            # Base Config
            ADMIN_PASSWORD: ${strAdminPassword}
            DBFILTER: ${strDbFilter}
            LIST_DB: ${boolListDb}
            LOG_LEVEL: ${enumLogLevel}
            UNACCENT: True
            PROXY_MODE: True
            WITHOUT_DEMO: True
            SERVER_WIDE_MODULES: ${strServerWideModules}
            # Performance Config
            WORKERS: ${intWorkers}
            MAX_CRON_THREADS: ${intMaxCronThreads}
            DB_MAXCONN: ${intDbMaxconn}
            LIMIT_MEMORY_HARD: ${intLimitMemoryHard}
            LIMIT_MEMORY_SOFT: ${intLimitMemorySoft}
            LIMIT_TIME_CPU: ${intLimiteTimeCpu}
            LIMIT_TIME_REAL: ${intLimiteTimeReal}
            LIMIT_TIME_REAL_CRON: ${intLimiteTimeRealCron}
            FILESTORE_COPY_HARD_LINK: True
            FILESTORE_OPERATIONS_THREADS: 3
            # SaaS Config
            SERVER_MODE: ${strServerMode}
            DISABLE_SESSION_GC: ${strDisableSessionGC}
            # Entrypoint
            WAIT_PG: True
            FIXDBS: ${strFixDbs}
            FIX_DB_WEB_DISABLED: True
            # Dynamic Entrypoint
            REPOS_YAML: ${multiReposYaml}
            CUSTOM_CONFIG: ${multiOdooConf}
            # SMTP Config
            SMTP_SERVER: ${strSmtpServer}
            SMTP_PORT: ${intSmtPort}
            SMTP_SSL: ${boolSmtpSsl}
            SMTP_USER: ${strSmtpUser}
            SMTP_PASSWORD: ${strSmtPassword}
            MAIL_CATCHALL_DOMAIN: ${strMailCatchallDomain}
            # Redis Config
{{- if eq .Values.enumSessionsStore "redis" }}
            ENABLE_REDIS: True
            REDIS_HOST: ${strRedisHost}
            REDIS_PORT: 6379
            REDIS_PASS: ${strRedisPass}
            REDIS_DBINDEX: 1
{{- end}}
            # Custom Environment Variables
            # NOTE: Do not change the indentation
{{- if .Values.multiEnvVariables }}
{{ .Values.multiEnvVariables | indent 12 }}
{{- end}}

            # GCE Proxy
    {{- if ne .Values.strGCECloudsqlConnectionName "" }}
    gce-psql-proxy:
        image: gcr.io/cloudsql-docker/gce-proxy:1.11
        network_mode: container:odoo
        command:
            - /cloud_sql_proxy
            - -instances=$strGCECloudsqlConnectionName=tcp:5432
        # labels:
        #    io.rancher.scheduler.affinity:container_label: io.rancher.stack_service.name=$${stack_name}/odoo
    {{- end}}

volumes:
  {{- if eq .Values.enumSessionsStore "filestore" }}
  $strOdooSessionsVolumeName:
    driver: rancher-nfs
    external: true
  {{- end}}
  $strOdooFilestoreVolumeName:
    driver: rancher-nfs
    external: true
