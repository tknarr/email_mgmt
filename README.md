    Postfix/Dovecot e-mail system installation
    Copyright 2017 Todd Knarr
    Licensed under the terms of the GPL v3.0 or any later version
    See the LICENSE file for complete terms
    
# EMail management service

I needed an e-mail setup where I could have users with a full shell account receive
mail through the usual Unix process with mail under their home directory, .forward
and procmail and such available, and so on. I also wanted to be able to set up
email-only accounts for friends without having to give them a full Unix shell
account they had no interest in in the process. I wanted it to be semi-automatic,
and I wanted to be able to manage/maintain it mostly through a Web interface. This
is the result. It uses MySQL for the database, Postfix and Dovecot for mail services.
Originally it used PHP for the Web interface, but I decided to switch to a more modern
approach (mostly as a learning exercise) using a Ruby on Rails API for the back-end
(this project) and a Vue.js application for the browser front-end.

##### More things I want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
