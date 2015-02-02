Description
===========

Installs [Cachet](https://cachethq.io/) and necessary frameworks and dependencies.

Requirements
============
## Ohai and Chef:

* Ohai: 6.14.0+

This cookbook makes use of `node['platform_family']` to simplify platform
selection logic. This attribute was introduced in Ohai v0.6.12.

## Platform:

The following platform families are supported:

* Debian
* RHEL

## Cookbooks:

* git
* nodejs

## Attributes

### default

* `node['cachet']['dbdriver']` - which database driver to use

Recipes
=======

## default

Installs basic Cachet web application

Usage
=====

hmmm

License and Author
==================

- Author:: Benjamin Chrobot (<benjamin.blair.chrobot@gmail.com>)