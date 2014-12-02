#!/bin/sh
# -*- coding: utf-8 -*-

# Installation de Cavote (développement)
# --------------------------------------

# TODO: Stopper le script s'il n'y a pas la commande virtualenv

# Récupérer la dernière version de développement :
#    (L'option GIT_SSL_NO_VERIFY=true n'est pas nécessaire si le certificat 
#     autosigné a été ajouté de manière permanente au système)
  GIT_SSL_NO_VERIFY=true git clone https://code.ffdn.org/ffdn/cavote.git cavote_master

# Installation du virtualenv (requiert le package python-virtualenv)
  cd cavote_master
  virtualenv -p /usr/bin/python2.7 flask
  flask/bin/pip install -r requirements.txt

# Installation de la base de données :
  SCHEMA_SQL=`cat schema.sql schema_0.1.X_to_0.2.X.sql schema_0.2.X_to_0.3.X.sql`
  sqlite3 --init  /tmp/cavote.db "$SCHEMA_SQL"

# Modifiez les paramètres de settings.py pour qu'ils correspondent à votre installation
#   nano settings.py.example

# Renommer le fichier settings final
  mv settings.py.example settings.py

# Activer le virtualenv
  source flask/bin/activate

# Lancez le serveur en mode développement :
  ./main.py # & # Remettre le '&' pour lancer directement firefox 

# L'utilisateur par défaut peut être activé à l'adresse suivante:
#     (Modifiez en les identifiants de connection lors du premier accès.)
#   firefox http://localhost:5000/login/1/victory 

# Quand on a terminé, désactiver le virtualenv:
  deactivate

