# installing postgres

## adbs install

```bash
# install docker
brew install --cask docker
open /Applications/Docker.app

# download docker config + test data
cd ~/Downloads/
wget https://github.com/arselzer/adbs-postgres/archive/refs/tags/v1.zip
unzip v1.zip

# run docker script
cd ./adbs-postgres-1
sudo docker-compose up

# open web ui
open http://localhost:8080/
```

after the browser opens up:

- on the left side of the pgadmin ui, you will find an expandable item ’servers’.
- after 3 expansions, you will see the database postgres, where all tables for the exercise are located.
- in order to interact with postgres, you may use, for example, the query tool (tools>query tool) and the psql tool (tools>psql tool).

## default install

downloading and installing db:

```bash
# fix brew
brew doctor
brew cleanup
brew update
brew upgrade

# install postgres
brew install postgresql@16

echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@16/lib/pkgconfig"
rm /usr/local/var/postgres/postmaster.pid
brew link postgresql@13 --force

# install pgadmin
brew install --cask pgadmin4
```

```bash
# start postgres
LC_ALL="C" /opt/homebrew/opt/postgresql@16/bin/postgres -D /opt/homebrew/var/postgresql@16

# set up new user
createdb `whoami` # evaluated to your machines username
CREATE ROLE ??? WITH LOGIN PASSWORD 'XXX';
psql postgres -U ???

# open postgres terminal
psql -d postgres
psql postgres://???@localhost:5432/<database name>
```

config via pgadmin4:

- in the "connection" tab:
     - host name/address: http://localhost/
     - port: 5432 (the default postgresql port)
     - maintenance database: postgres
     - username: your macos username
     - password: leave this blank unless you've set a password for your postgresql user.

next run sql files from repository inside postgres: https://github.com/arselzer/adbs-postgres/
