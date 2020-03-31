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
git 
kubectl apply -f bookstore.yml

Tester
Créer une entrée DNS ou modifier le fichier host pour que le nom bookstoreapi.lacave pointe vers l'adresse IP externe d'un ou plusiers des noeuds du cluster.
On peut obtenir la liste des livres:
curl http://bookstoreapi.lacave/api/books