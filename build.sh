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

# ----------------------------------------------------------------------------------------------- create superuser account
# create superuser account
echo "${green}creating superuser account${reset}"
username="postgres"
password="password"
psql postgres -c "CREATE USER $username SUPERUSER PASSWORD '$password';"

# ----------------------------------------------------------------------------------------------- delete everything
getUsers() {
    psql postgres -t -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;"
}
getTables() {
    psql $1 -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
}
getDatabases() {
    psql postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"
}

# delete tables
echo "${green}deleting tables${reset}"
databases=($(getDatabases))
for database in "${databases[@]}"; do
    tables=($(getTables $database))
    for table in "${tables[@]}"; do
        echo "deleting table: $table"
        psql $database -c "DROP TABLE IF EXISTS $table CASCADE;"
    done
done
echo "tables left:"
psql postgres -c "\dt"

# delete databases
echo "${green}deleting databases${reset}"
databases=($(getDatabases))
for database in "${databases[@]}"; do
    if [ "$database" = "postgres" ]; then
        echo "skipping database: $database"
        continue
    fi

    echo "deleting database: $database"
    psql postgres -c "DROP DATABASE IF EXISTS $database"
done
echo "databases left:"
psql postgres -c "\l"

# iterate through users
echo "${green}deleting users${reset}"
users=($(getUsers))
for user in "${users[@]}"; do
    echo "deleting user: $user"
    sudo -u postgres psql -c "DROP ROLE $user;"
done
echo "users left:"
psql postgres -c "\du"

# ----------------------------------------------------------------------------------------------- create new user and database
# create user account
echo "${green}creating user account${reset}"
username=$(whoami)
password="password"
psql postgres -c "CREATE ROLE $username WITH LOGIN PASSWORD '$password';"
psql postgres -c "ALTER ROLE $username CREATEDB;"

# delete database if it exists
database="testdb"
# psql postgres -c "DROP DATABASE IF EXISTS $database;"

# create database
# echo "${green}creating database${reset}"
# psql postgres -c "CREATE DATABASE $database WITH OWNER $username;"
# psql $database -c "GRANT ALL PRIVILEGES ON DATABASE $database TO $username;"
# psql $database -c "CREATE SCHEMA public;"
# psql $database -c "GRANT ALL PRIVILEGES ON DATABASE $database TO public;"

# ----------------------------------------------------------------------------------------------- run sql scripts
# run all sql scripts
echo "${green}running sql scripts${reset}"
path="./scripts/*.sql"
for file in $path; do
    echo "running: $file"
    psql $database -v ON_ERROR_STOP=1 -f $file
done
