# install docker
brew install --cask docker
open /Applications/Docker.app

# download and run docker compose script
cd ~/Downloads/
wget https://github.com/arselzer/adbs-postgres/archive/refs/tags/v1.zip
unzip v1.zip
cd ./adbs-postgres-1
sudo docker-compose up

# open web ui
open http://localhost:8080/

# after the browser opens up:
# - on the left side of the pgadmin ui, you will find an expandable item 'servers'.
# - after 3 expansions, you will see the database postgres, where all tables for the exercise are located.
# - in order to interact with postgres, you may use, for example, the query tool (tools>query tool) and the psql tool (tools>psql tool).
