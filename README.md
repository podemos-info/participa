Podemos Juntos
============================================

El objetivo de esta aplicación es ofrecer una interfaz a los usuarios donde inscribirse a Podemos, 
así como poder iniciar sesión y modificar sus datos en la plataforma y tener acceso al listado de 
Herramientas oficiales (Reddit, Agora Voting, App Gree).

Instalación 
-----------

Es una aplicación Ruby On Rails hecha con Rails 4.1 / Ruby 2.0.
Se recomienda hacerla en sistemas operativos GNU/Linux (nosotros usamos Ubuntu).
Para manejar las gemas recomendamos rvm o rbenv.
Para la BBDD recomendamos postgres, pero se puede usar también mysql/sqlite3. 

Una vez se tenga configurado el rvm o rbenv los pasos a seguir serían los siguientes:

```
bundle install
cp config/database.yml.example config/database.yml 
cp config/secrets.yml.example config/secrets.yml 
rake db:migrate
rails server 
```

Aparte de esto para algunas acciones utilizamos [resque](), una cola para trabajos asincronos. 

Tests
-----

Se pueden comprobar los tests con 

```
rake test
```

Todos deberían dar OK o SKIP (significa que se ipasa de alto, y que hay que programarlo). Una vez se libere el código se integrará con [travis-sci](http://travis-ci.org/).

APIs externas
-------------

* Para las votaciones de los usuarios usamos [Agora Voting](https://agoravoting.com/), que han realizado una integración con la plataforma de Podemos. La configuración del secreto compartido se encuentra en una clave de `secrets.yml`. Documentación: [Sobre la integración, al momento de escribir esto](https://github.com/agoravoting/agora-core-view/blob/9dfbbf5252b2eb119463d2dcaa2c01391b232653/INTEGRATION.md), [Sobre la integración, versión más actualizada](https://github.com/agoravoting/agora-core-view/blob/master/INTEGRATION.md), [Sobre la API REST general de AgoraVoting](https://agora-ciudadana.readthedocs.org/).

* Para el envío de SMS usamos [esendex](http://esendex.es/). Puede comprobarse con el comando `rake esendex:validate[username,password,account_reference]`. La configuración de la autenticación se encuentra en unas claves de `secrets.yml`.

* Para el control de excepciones en staging y production usamos una instancia privada de la Asociación aLabs de [errbit](https://github.com/errbit/errbit), una aplicación libre basada en la API de [airbrake](https://airbrake.io/). Puede comprobarse la conexión con el servidor con el comando `rake airbrake:test`. La configuración de la autenticación se encuentra en unas claves de `secrets.yml`.

* Para la gestión de las colas de trabajo utilizamos [resque](https://github.com/resque/resque/), que usa como DDBB redis. Un comando útil para desarrollo es el de iniciar un worker: `rake resque:work` 

* En desarrollo, para comprobar el envio de correos, utilizamos [mailcatcher](http://mailcatcher.me/), una gema que levanta un servidor SMTP en el puerto 1025 y una interfaz web para ver los correo s que se envían en en el puerto 1080. Para levantarlo ejecutar el comando `mailcatcher`

* Para el envío de correo en producción usamos [Amazon SES](http://aws.amazon.com/es/ses/). La configuración va en `config/secrets.yml`.

Dependencias
------------

Para ejecutar la aplicación en su totalidad hay que tener los siguientes servicios en funcionamiento: 

```
sudo apt-get install postgres                       # para la base de datos, o mysql-server si lo prefieres
sudo apt-get install imagemagick                    # para la generación del captcha
sudo apt-get install redis-server                   # para la gestión de las colas de trabajo (resque)
```

Configuraciones
---------------

Se ha intentado que todas las configuraciones esten accessibles con los ficheros de configuración

```
config/databases.yml
config/secrets.yml
```

Ver ejemplos en `config/databases.yml.example` y `config/secrets.yml`.

i18n
----

Para modificar los distintos idiomas, revisar los ficheros de `config/locales/` 
Para agregar uno nuevo se deben seguir los siguientes pasos: 
* Agregarlo en la línea de 'scope locale' en `config/routes` 
* Agregarlo en la UI de cambio de idiomas del footer en `app/views/layouts/application.html.erb`
* Agregarlo en la configuración para idiomas válidos en `config/application.rb`

Newsletter
----------

En el admin se puede descargar un CSV de todos los correos de usuarios que hayan aceptado recibir la newsletter. *Atención* No hay integración con Sendit o la plataforma de envío de boletines que utiliza Podemos, por lo que no hay ningún tipo de sincronización (si un usuario se da de baja de Sendit puede volver a darse de alta de forma automática por la importación del CSV).
