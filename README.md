Construction du conteneur Mongo

cd mongodb
docker build --tag elfelip01/mongobookstore:latest .
docker push elfelip01/mongobookstore:latest

Construction du conteneur applicatif
cd BookApi
docker build --tag elfelip01/booksapi:latest .
docker push elfelip01/booksapi:latest

Déploiement
Pour déployer, kubectl doit être installé et configuré pour se connecter au cluster.

kubectl apply -f bookstore.yml