# homecourier-backend

* Ruby 2.6.6

* Rails 5.2.4.3

* Configuración:
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

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions