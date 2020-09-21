# homecourier-backend

* Ruby 2.6.6

* Rails 5.2.4.3

* Configuración

Antes que nada realizar bundle install en el directorio base.

* Iniciar postgres

sudo /etc/init.d/postgresql start

* Creación base de datos

Se debe tener el usuario postgres configurado con contraseña "postgres":

```
sudo -u postgres psql
\password postgres
\q
```
y luego crear la base de datos
```
rails db:create
```

* Como trabajar sobre el repositorio:

Cada vez que se empiece a trabajar con algo nuevo se debe crear una rama siguiendo la nomenclatura especificada en el roadmap de gestion de la configuración:
```
git checkout -b nombre_rama
```

Mientras que uno esté trabajando sobre este artefacto debe hacer commits solo a esa rama, cuando esta listo se debe crear una pull request desde la pagina de github, se debe ir a la rama y hay un boton especifico para eso.

Una vez que fue revisado por las personas correspondientes se hace el merge.

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
