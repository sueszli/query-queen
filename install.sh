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
