# Welcome to Home on Rails

## What's Home on Rails

Home on Rails is a ruby-on-rails based framework that includes everything needed to create IoT web applications.


## Model layer

Home on Rails представляет иерархию классов, базирующуюся на Active Record-моделях:

    Entity
        Device
            Sensor
                Motion
                Temperature
                Humidity
                Door
                Switch
                ...
            Actor
                Fan
                Light
                Boiler 
                FacadeBlind
                ...
            Server
        Widget
            Slider
            Select
            Button
            Chart
            ...
        Placement
            Flat
            Room
            Floor
            House
        Person

Для взаимодействия с физическими объектами служит набор драйверов:
	
       Mqtt
       Gpio
       OneWire
       Uart
	...

Каждый объект в проекте – это экземпляр какого-либо класса с подключённым модулем драйвера. Кроме того, объекты образуют свою собственную иерархию – у каждого из них есть свойство **parent**.
Кроме parent-а объекты также обладают следующими свойствами:
       name : для обращения к объекту в программном коде
	caption : для отображения на веб-сайте
	driver : протокол для взаимодействия с физическими объектами
	class : чем является объект (Комната, выключатель, датчик и т.д.)
	value : (float) текущее значение
	behavior_script : программный код, расширяющий возможности объекта


## DSL

Для программирования логики взаимодействия объектов служит язык прикладной области, основанный на модели событий. Примеры событий:
	at_change
	at_on
	at_off
	at_schedule
	at_click
	...

Все эти события программируются через web-интерфейс и хранятся для в поле behavior_script для каждого объекта отдельно.

Пример реакции на датчик движения:

	at_change do
		light1.on! 5.minutes
	end



## Getting Started

Install Ruby on Rails (currently tested versions 5.1.6 and 4.2.1) at the command prompt if you haven't yet:

        $ gem install rails -v 5.1.6

At the command prompt, create a new Rails application:

        $ rails new myapp

   where "myapp" is the application name.

Change directory to `myapp` and add the next rows into Gemfile:
 
        gem 'home', git: ' https://github.com/uratol/Home-on-Rails.git'
        gem 'jquery-rails'
        gem 'rails-ujs'
        gem 'jquery_context_menu-rails'


Run:

        $ bundle install

Run install task. It will make and populate the database, create a default user and config file

        $ rake home:install

Add the next line to begin of file: app/assets/javascript/application.js
        
        //= require home/application


Add the next line to begin of file: app/assets/stylesheets/application.css
        
        *= require home/application

Delete next files:
        
        app/views/layouts/application.html.erb
        app/controllers/application_controller.rb

Add the route to config/routes.rb 

       mount Home::Engine, at: "/"

Run the server:

     	$ rails server

Go to `http://localhost:3000` and you have a goal!



