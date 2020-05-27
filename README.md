# Projet Demo dotnet dev/ops
Ce projet est un tutoriel qui permet d'apprendre comment gérer un projet dotnet core en mode dev/ops.
Le principe démontré est l'infrastructure as code. Ce projet contient donc tous les éléments logiciel et d'infrastructure permettant de le faire fonctionner.

## Éléments de projet
Ce projet contient les éléments suivants:

    Un conteneur MongoDB pour stocker les données du service web.
    Un service web de gestion de librairie (ou on vend des livres)
    Un realm Keycloak pour la gestion des identités et des accès.
    Un fichier de déploiement Kubernetes
    Un script de test pour le service web.

## Pré-requis
Visual studio code a été utilisé pour le développement. Les extensions dotnet, Docker, Kubernetes sont utiles.
Docker doit être installé sur le poste de développement.
Un accès à un cluster Kubernetes ou une installation locale de minikube sont nécessaire.
L'outil kubectl doit être installé sur le poste de développement et configuré pour accéder au cluster kubernetes ou au Minikube.
Un DNS est très utile pour publier les adresses ip des noeuds du cluster Kubernetes et de les associer aux différents URL ingress du projet.
Un compte sur Dockerhub est nécessaire pour publier les images Docker. Le repository interne de Kubernetes peut aussi être utilisé.

Dans son état actuel, les images Docker sont envoyé sur Dockerhub en utilisant mon compte.
La zone DNS lacave est utilisé et on assume que les entrés suivantes sont dans la zone.
kube                    A       192.168.1.21
                        A       192.168.1.22
                        A       192.168.1.23
bookstoreapi            CNAME   kube.lacave.
keycloak                CNAME   kube.lacave.

# Configurer un repository Docker
La manière la plus simple d'avoir un dépôt pour les images Docker est de se créer un compte sur Docker Hub. Dans ce cas, le dépôt aura votre nom d'utilisateur.
Il faut aller créer les projets mongobookstore et booksapi
Remplacer Votre-Docker-Repo par votre nom d'utilisateur Docker Hub dans les commandes des étapes suivantes.

Dans le cas ou vous utilisez un registre privé, on doit alors s'y authentifier et créer le crédentiels
Pour s'y authentfierl lancer la commande docker login:

    docker login docker.lacave

Fournir l'utilisateur et le mot de passe. Pour l'ajout du crédentiel dans Kubernetes, ca se fait un fois le namepsace créé.

# Construction des images du projet
Construction de l'image Mongo

cd mongodb
docker build --tag Votre-Docker-Repo/mongobookstore:latest .
docker push Votre-Docker-Repo/mongobookstore:latest

Construction du conteneur applicatif
cd BookApi
docker build --tag Votre-Docker-Repo/booksapi:latest .
docker push Votre-Docker-Repo/booksapi:oidc

# Autorité de certification
Pour pouvoir fédérer des fournisseurs d'identités comme Google, Microsoft ou Facebook, il est important que le serveur d'authentification soit exposé en HTTPS en utilistant le protocol TLS.
Pour pouvoir créer des certificats à l'intérieur de Kubernetes, on créé une autorité de certification selfsigned.
Pour créer l'autorité de certification, lancer le fichier de déploiement cert/root-ca-cert-manager.yml

    kubectl apply -f cert/root-ca-cert-manager.yml

Pour que votre système fasse confiance à cet autorité de certification, vous devez ajouter le certificat BooksApi/cert/ca-root.crt dans les autorités de certification de confiance du magasin de certificat de votre système. Si vous utilisez Firefox, ce certificat doit aussi être ajouté aux autorités de certification de confiance du navigateur.

# Déploiement
Pour déployer, kubectl doit être installé et configuré pour se connecter au cluster.
Le fichier de déploiement bookstore.yml contient l'ensemble des configuration permettant de déployer l'application et les services nécessaires.

Le namespace bookstore est créé et tous les composants y sont déployé.

La première étape est d'aller ajuster les images Docker du Mongo et du bookstoreapi dans le fichier de déploiement bookstore.yml.

Pour déployer le système, lancer la commande suivante.

    kubectl apply -f bookstore.yml

# Créer le secret pour pouvoir accéder aux images des dépôts privés

Créer le secret dans Kubernetes:

    kubectl create secret generic regcred --from-file=.dockerconfigjson=${HOME}/.docker/config.json --type=kubernetes.io/dockerconfigjson -n bookstore

# Configurer le serveur d'authentifcation
Le fichier de déploiement Kubernetes déploie un serveur d'authentification Keycloak: https://www.keycloak.org

On peut accéder au serveur par l'url http://keycloak.lacave
S'authentifier avec les inpofrmation suivantes:
    username: admin
    password: admin

Le première étape est de créer le royaume bookstore:
    Dans l'interface principale, déplacer la souris vers le realm Master, cliquer sur le bouton Add realm.
    Cliquer sur le bouton Select file de l'item import.
    Sélectionner le fichier keycloak/bookstore-realm.json
    Laisser bookstore dans Name
    Laisser Enabled à On
    Cliquer sur le bouton create

Le royaume contient 2 clients:
    bookstoreui: Client de type confidentiel pour l'éventuel interface utilisateur
    bookstoreapi: Client de type bearer only pour les services web.

On doit faire générer de nouveau client secret pour les deux clients:
    Sélectionner le realm bookstore
    Aller dans client et cliquer sur le client bookstoreapi
    Dans l'onglet credentials cliquer sur le bouton Regenerate Secret
    Prendendre en note le secret et le mettre dans le fichier BooksApi/appsettings.json
    Faire la même chose pour le client bookstoreui
    Mettre le secret dans le script de tests: tests/testApi.sh

Reconstruire l'image du bookstore
Pousser la nouvelle image sur le repository (dockerhub)
Supprimer le pod bookstoreapi, il va automatiquement se redéployer avec la nouvelle image

Finalement on doit créer 3 utilisateurs:
    gontran/toto1234: lui donner le rôle customer du client bookstoreapi
    ginette/toto1234: lui donner le rôle employee du client bookstoreapi
    julio/toto1234: lui donner le rôle admin du client bookstoreapi

 
# Tester
On peut obtenir la liste des livres:
curl http://bookstoreapi.lacave/api/books

On peut utiliser le script shell tests/testApi.sh