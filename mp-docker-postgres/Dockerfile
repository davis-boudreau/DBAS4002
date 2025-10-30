FROM postgres:18
LABEL maintainer="student@nscc.ca" \
      description="Dockerized PostgreSQL for Event Management System"

COPY sql/00_init /docker-entrypoint-initdb.d/
EXPOSE 5432

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s \
  CMD pg_isready -U ${POSTGRES_USER:-app_user} -d ${POSTGRES_DB:-event_db} || exit 1