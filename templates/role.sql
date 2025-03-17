sqlScripts:
  roles: |
    DO $$ 
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_role') THEN
            CREATE ROLE app_role WITH LOGIN PASSWORD 'securepassword';
        END IF;

        IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'app_user') THEN
            CREATE USER app_user WITH PASSWORD 'userpassword' IN ROLE app_role;
        END IF;
    END $$;

  grants: |
    DO $$
    BEGIN
        GRANT CONNECT ON DATABASE postgres TO app_role;
        GRANT USAGE ON SCHEMA public TO app_role;
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_role;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_role;
    END $$;
