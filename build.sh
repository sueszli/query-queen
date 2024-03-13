if ! command -v psql &>/dev/null; then
    echo "postgres is not installed"
    return
fi
if [ "$(id -u)" != "0" ]; then
    echo "this script must be run as root or with sudo privileges"
    return
fi

# ----------------------------------------------------------------------------------------------- generate users
# create superuser account
username="postgres"
password="password"
psql postgres -c "CREATE USER $username SUPERUSER PASSWORD '$password';"
sudo -u postgres psql

# ----------------------------------------------------------------------------------------------- wipe postgres
# delete all databases as superuser
databases=($(psql postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"))
for database in "${databases[@]}"; do
    if [ "$database" == "postgres" ]; then
        echo "skipping database: $database"
        continue
    fi
    echo "deleting database: $database"

    sudo psql postgres -c "DROP DATABASE $database;"
done
echo "databases left: $(psql postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")"

# delete each user
users=($(psql postgres -t -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;"))
for user in "${users[@]}"; do
    echo "deleting user: $user"

    sudo psql postgres -c "DROP ROLE $user;"
done
echo "users left: $(psql postgres -t -c "SELECT rolname FROM pg_roles WHERE rolcanlogin = true;")"

# ----------------------------------------------------------------------------------------------- generate user
# create user account
username=$(whoami)
password="password"
psql postgres -c "CREATE ROLE $username WITH LOGIN PASSWORD '$password';"
psql postgres -c "ALTER ROLE $username CREATEDB;"

# create database
database="testdb"
psql postgres -c "CREATE DATABASE $database;"
psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $database TO $username;"

# -------------------------------------------------------------- test: print table
# create table
table="demodata"
psql $database -c "DROP TABLE IF EXISTS $table;"
psql $database -c "CREATE TABLE $table (id SERIAL PRIMARY KEY, string VARCHAR(100));"

#  add data
psql $database -c "INSERT INTO $table (string) VALUES ('one');"
psql $database -c "INSERT INTO $table (string) VALUES ('two');"
psql $database -c "INSERT INTO $table (string) VALUES ('three');"

# print contents
psql $database -c "SELECT * FROM $table;"
psql $database -c "DROP TABLE IF EXISTS $table;"
