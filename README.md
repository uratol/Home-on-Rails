## What's Home on Rails

**Home on Rails** is a ruby-on-rails based framework that includes everything needed to create IoT web applications.

## Model layer

**Home on Rails** provides the class hierarchy based on Active Record-models:

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

For interaction with physical objects serves a set of drivers (ruby modules):
	
        Mqtt
        Gpio
        OneWire
        Uart
        ...

Each object in the project is an instance of a class with an extended driver module. In addition, objects form their own hierarchy - each of them has the property **parent**.
Except for **parent** objects also have the next properties:
       
    name : for address in a program code
    caption : for display on UI
    driver : a protocol for interaction with physical objects
    class : what is the object (Room, switch, sensor, etc.)
    value : (float) current object value
    behavior_script : program code that extends the functionality of an object


## DSL

For programming the objects interaction serves the Domain Specific Language based on the event model. Examples of events:
	at_change
	at_on
	at_off
	at_schedule
	at_click
	...

All these events are programmed via the web interface and stored in the **behavior_script** field for an each object separately.
Example of response on a motion sensor:

    at_change do
        light1.on! 5.minutes
    end


## Getting Started

Install Ruby on Rails (currently tested versions are 5.1.6 and 4.2.1) at the command prompt if you haven't yet:

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

Add the next line at the begin of file: app/assets/javascript/application.js
        
        //= require home/application


Add the next line at begin of file: app/assets/stylesheets/application.css
        
        *= require home/application

Delete next files:
        
        app/views/layouts/application.html.erb
        app/controllers/application_controller.rb

Add the route to config/routes.rb 

       mount Home::Engine, at: "/"

Run the server:

     	$ rails server

Go to **http://localhost:3000** and you achieved the goal!

To authenticate use the credentials:

Login: **demo@example.com**
Password: **demo12345**


