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
    echo "deleting database: $database"
    psql postgres -c "DROP DATABASE IF EXISTS $database"
done
echo "databases left:"
psql postgres -c "\l"

# delete users
echo "${green}deleting users${reset}"
users=($(getUsers))
for user in "${users[@]}"; do
    echo "deleting user: $user"
    psql postgres -c "DROP USER IF EXISTS \"$user\";"
done
echo "users left:"
psql postgres -c "\du"

# ----------------------------------------------------------------------------------------------- run scripts
# run all scripts
path="./scripts/*.sql"
for file in $path; do
    echo "${green}running script: $file${reset}"
    psql postgres -v ON_ERROR_STOP=1 -f $file
done

# print
echo "${green}done!${reset}"
psql postgres -c "\dt"
