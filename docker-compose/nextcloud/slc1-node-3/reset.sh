docker compose down
sudo rm -rf nextcloud-db
sudo rm -rf data
mkdir data
mkdir nextcloud-db
docker compose up -d
