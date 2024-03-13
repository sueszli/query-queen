green=`tput setaf 2`
reset=`tput sgr0`

if ! command -v psql &>/dev/null; then
    echo "postgres is not installed"
    return
fi
if [ "$(id -u)" != "0" ]; then
    echo "this script must be run as root or with sudo privileges"
    return
fi

# ----------------------------------------------------------------------------------------------- delete everything
# create superuser account
echo "${green}creating superuser account${reset}"
username="postgres"
psql postgres -c "CREATE USER $username SUPERUSER"
sudo -u postgres psql

# delete all databases
echo "${green}deleting all databases${reset}"
databases=($(psql postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"))
for database in "${databases[@]}"; do
    if [ "$database" == "postgres" ]; then
        echo "skipping database: $database"
        continue
    fi
    echo "deleting database: $database"
    sudo -u postgres psql -c "DROP DATABASE $database;"
done
echo "databases left:"
psql postgres -c "\l"

# delete each user
echo "${green}deleting all users${reset}"
users=($(psql postgres -t -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;"))
for user in "${users[@]}"; do
    echo "deleting user: $user"
    sudo -u postgres psql -c "DROP ROLE $user;"
done
echo "users left:"
psql postgres -c "\du"

# ----------------------------------------------------------------------------------------------- generate user and database
# create user account
echo "${green}creating user account${reset}"
username=$(whoami)
password="password"
psql postgres -c "CREATE ROLE $username WITH LOGIN PASSWORD '$password';"
psql postgres -c "ALTER ROLE $username CREATEDB;"

# create database
echo "${green}creating database${reset}"
database="testdb"
psql postgres -c "CREATE DATABASE $database WITH OWNER $username;"
psql $database -c "CREATE SCHEMA public;"
psql $database -c "GRANT ALL PRIVILEGES ON SCHEMA public TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON DATABASE $database TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO public;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO public;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO public;"
psql $database -c "GRANT ALL PRIVILEGES ON DATABASE $database TO public;"
psql $database -c "GRANT ALL PRIVILEGES ON SCHEMA public TO public;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $username;"
psql $database -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $username;"

# ----------------------------------------------------------------------------------------------- run sql scripts
# delete all tables
echo "${green}deleting all tables${reset}"
tables=($(psql $database -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"))
for table in "${tables[@]}"; do
    echo "deleting table: $table"
    psql $database -c "DROP TABLE $table;"
done
echo "tables left:"
psql $database -c "\dt"

# run all sql scripts
echo "${green}running sql scripts${reset}"
path="./scripts/*.sql"
for file in $path; do
    echo "running: $file"
    psql $database -v ON_ERROR_STOP=1 -f $file
done
