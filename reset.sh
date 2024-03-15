green=`tput setaf 2`
reset=`tput sgr0`

if ! command -v psql &>/dev/null; then
    echo "postgres is not installed"
    exit 1
fi

# ----------------------------------------------------------------------------------------------- delete everything
getUsers() {
    psql postgres -t -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;"
}
getTables() {
    psql $1 -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
}
getIndexes() {
    psql $1 -t -c "SELECT indexname FROM pg_indexes WHERE schemaname = 'public';"
}
getViews() {
    psql $1 -t -c "SELECT viewname FROM pg_views WHERE schemaname = 'public';"
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

# delete indexes
echo "${green}deleting indexes${reset}"
indexes=($(getIndexes))
for index in "${indexes[@]}"; do
    echo "deleting index: $index"
    psql postgres -c "DROP INDEX IF EXISTS $index;"
done
echo "indexes left:"

# delete views
echo "${green}deleting views${reset}"
views=($(getViews))
for view in "${views[@]}"; do
    echo "deleting view: $view"
    psql postgres -c "DROP VIEW IF EXISTS $view;"
done
echo "views left:"
psql postgres -c "\dv"

# delete databases
echo "${green}deleting databases${reset}"
databases=($(getDatabases))
for database in "${databases[@]}"; do
    echo "deleting database: $database"
    psql postgres -c "DROP DATABASE IF EXISTS $database"
done
echo "databases left:"

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
