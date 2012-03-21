Rails Locale Sorter
===================
This is a small utility to assist in handling your I18n YAML files in a Ruby on Rails project.

Installation
============
```
$ gem install rails_locale_sorter
```

Creating/Applying Patches
=========================
To create a patch, just provide input and output directories, and a "source of truth" locale that will be the template for the other languages.

```
$ locale_patch path/to/locales path/to/output en.yml
```

The output directory will now contain a list of YAML files containing missing translations.

Once the strings have been translated, they can be applied back into your project:

```
$ locale_apply path/to/translated_patches path/to/locales
```
The patching process also sorts the file's content alphabetically.

Defaults
========
These commands default to "locales/", "new-locales/", and "en.yml". Meaning that all you need to do to run through the entire process is:

```
$ cd my_rails_app/config
$ locale_patch
$ locale_apply
```

Or use the handy, descriptive aliases:

```
$ cd my_rails_app/config
$ poop
$ scoop
```
