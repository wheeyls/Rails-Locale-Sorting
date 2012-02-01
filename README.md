Rails Locale Sorter
===================
This is a small utility to assist in generating language files, so that as you add strings to your locale files you can have them translated quickly.

Installation
============
```
$ gem install rails_locale_sorter
```

Generating New Files
====================
The command tool that comes with the gem will go through your locales directory, and update all the locale files based on your "default" language.

For instance, if I've added keys to the en.yml file, then the command will create new yaml files for es.yml, zh.yml, etc with blank values set as the new keys.

It defaults to english as the base language; you can change it by passing in a parameter.
```
$ locale_generator path/to/locales path/to/output [en.yml]
```
