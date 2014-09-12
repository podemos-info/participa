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
rake db:migrate
rails server 
```
