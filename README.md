Système de vote pour associations
=================================

Développé pour et par des membres de la Fédération FDN (http://ffdn.org)

Installation (développement)
----------------------------

Dépendances :

 - python (testé avec python 2.7
 - python-openid
 - sqlite3
 - Flask
 - Flask-OpenID

Récupérer la dernière version de développement :
`$ git clone git@git.ndn.cx:cavote.git`

Installation de la base de données :
`$ sqlite3 /path/to/cavote.db
 > .read schema.sql`
 
Modifiez les paramètres de settings.py pour qu'ils correspondent à votre installation

Lancez le serveur en mode développement :
`$ python main.py`

Dans un navigateur, vous pourrez à cavote à l'adresse
<http://localhost:5000/>.

L'utilisateur par défaut peut être activé à l'adresse
<http://localhost:5000/login/1/victory>. Modifiez en les
identifiants de connection lors du premier accès.


Traduction
----------

Génération du template de chaînes à traduire :
    
    pybabel extract -F babel.cfg -o messages.pot .

Génération du catalogue d'une langue en particulier :

    pybabel init -i messages.pot -d translations -l fr

Une fois la traduction effectuée :
    
    pybabel compile -d translations

Si les chaînes changent :

    pybabel extract -F babel.cfg -o messages.pot .
    pybabel update -i messages.pot -d translations


Installation (production)
-------------------------

Les étapes pour l'installation en mode production sont les
mêmes qu'en mode développement, jusqu'à l'étape de lancement
du serveur.

NDN a choisi d'utiliser gunicorn pour mettre en production
son instance de cavote.

Pour celà, installez gunicorn (dépendant de votre distribution).

Dans le répertoire de cavote, tappez :
`gunicorn -w 4 -b 192.168.122.104:8000 main:app -D`

 - -w 4 signifie que gunicorn lancera 4 "workers", ce qui devrait amplement suffir
 - remplacez l'adresse IP et le port par votre configuration. L'adresse IP doit
 correspondre à qu'appellera votre serveur web en frontend (nous utiliserons nginx dans l'exemple).
 Si ce frontend est situé sur la même machine que cavote, l'adresse IP sera 127.0.0.1.
 - De même, changez de port si vous souhaitez en utiliser un autre
 - -D signifie que gunicorn sera lancé en daemon. 
   - Enlever vous permettrait de tester et pouvoir fermer le serveur en tappant Ctrl+C 
   - En mode daemon, un `pkill gunicorn` killera vos workers gunicorn

Pour activer les notifications par mail, mettez en place une tache cron appelant le script `reminder.py`.

Configurez nginx (`/etc/nginx/sites-enabled` ou `/etc/nginx/nginx.conf` ou
autre selon votre système)

		server {
		  listen       <votre-ip>:80;
		  server_name  <votre-url-cavote>;
		  rewrite      ^(.*) https://<votre-url-cavote>$1 permanent;
		}
		
		#
		# FIXME: specify correct value(s) for `server_name` directive and
		#        `ssl_certificate` + `ssl_certificate_key` directives below
		#
		server {
		  listen       <votre-ip>:443;
		  server_name  <votre-url-cavote>;
		  ## make sure you change location if you did clone into /usr/local/app
		
		  ssl on;
		  ssl_certificate      /path/to/<votre_certificat_ssl>.crt;
		  ssl_certificate_key  /path/to/<votre_certificat_ssl>.key;
		  # enable better ssl security if you like to mitigate BEAST and other exploits
		  #ssl_session_cache       shared:SSL:10m;
		  #ssl_session_timeout     5m;
		  ssl_protocols           SSLv3 TLSv1;
		  ssl_ciphers             ECDHE-RSA-AES256-SHA384:AES256-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH:!AESGCM;
		  ssl_prefer_server_ciphers on;
		  #add_header              Strict-Transport-Security max-age=500;
		  #ssl_ecdh_curve          secp521r1;
		
		
		#
		# FIXME: modify the `rewrite` directive below to point to proper S3 bucket
		#        and path or comment out if you will store images on local file system
		#
		location / {
		  proxy_pass        http://192.168.122.104:8000;
		  proxy_set_header  X-Real-IP  $remote_addr;
		  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		  proxy_set_header Host $http_host;
		  proxy_set_header X-Forwarded-Proto https;
		  proxy_redirect off;
		  client_max_body_size 4M;
		  client_body_buffer_size 128K;
		}
		
		  error_page 500 502 503 504 /50x.html;
		  location = /50x.html {
		  root html;
		  }
		}


Modifiez les valeurs correspondant a la configuration de votre installation.
Dans l'exemple ci dessus, cavote sera disponible automatiquement et uniquement
en HTTPS.

Licence
-------

La licence appliquée est la GNU/AGPLv3

Contributeurs
-------------

 - Julien Rabier
 - Guillaume Subiron
 - Arnaud Delcasse
 - Pierre 'Rogdham' Pavlidès

