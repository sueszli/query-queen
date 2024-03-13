# installing postgres on macos

first install postgres and pgadmin via homebrew:

```bash
# update homebrew
brew doctor
brew cleanup
brew update
brew upgrade

# download postgres
brew install postgresql@16

# link everything
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@16/lib/pkgconfig"
rm /usr/local/var/postgres/postmaster.pid
brew link postgresql@13 --force

# download pgadmin
brew install --cask pgadmin4
```

then set up a new user and database:

```bash
# start postgres
LC_ALL="C" /opt/homebrew/opt/postgresql@16/bin/postgres -D /opt/homebrew/var/postgresql@16

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
