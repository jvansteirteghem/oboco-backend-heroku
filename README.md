# oboco-backend-heroku

[oboco-backend](https://gitlab.com/jeeto/oboco-backend) for heroku (work in progress).

## requirements

- heroku cli
- docker

## configuration

- docker
	- select "settings"
	- select "resources"
	- set "memory" to "6.00 gb"
- heroku
	- create app oboco-backend
		- heroku login
		- heroku config:set TZ=Europe/Brussels --app oboco-backend
		- heroku config:set SECRET=secret --app oboco-backend
		- heroku config --app oboco-backend
	- add heroku-postgresql to oboco-backend
	- create database
		- heroku login
		- heroku pg:info --app oboco-backend
		- heroku pg:credentials:url DATABASE --app oboco-backend
		- connect to postgresql
		- execute oboco-backend/src/non-packaged-resources/database_postgresql.ddl
		- execute oboco-backend/src/non-packaged-resources/database_postgresql.sql

## build

- heroku container:login
- heroku container:push web --app oboco-backend

## run

- heroku container:release web --app oboco-backend
- heroku logs --tail --app oboco-backend

## test

- heroku open --app oboco-backend (https://oboco-backend.herokuapp.com/swagger-ui/)

## development

- clone
	- git clone --recurse-submodules https://gitlab.com/jeeto/oboco-backend-heroku.git
- add oboco-backend
	- git submodule add https://gitlab.com/jeeto/oboco-backend.git
	- git submodule init
- pull oboco-backend
	- cd oboco-backend
	- git pull
- configuration
	- .env
- build
	- docker-compose build
- run
	- docker-compose up
- test
	- http://127.0.0.1:8080/swagger-ui/