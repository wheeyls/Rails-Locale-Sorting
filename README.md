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
