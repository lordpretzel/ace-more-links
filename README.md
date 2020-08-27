[![License: GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)
<!-- [![GitHub release](https://img.shields.io/github/release/lordpretzel/avy-more-links.svg?maxAge=86400)](https://github.com/lordpretzel/avy-more-links/releases) -->
<!-- [![MELPA Stable](http://stable.melpa.org/packages/avy-more-links-badge.svg)](http://stable.melpa.org/#/avy-more-links) -->
<!-- [![MELPA](http://melpa.org/packages/avy-more-links-badge.svg)](http://melpa.org/#/avy-more-links) -->
[![Build Status](https://secure.travis-ci.org/lordpretzel/avy-more-links.png)](http://travis-ci.org/lordpretzel/avy-more-links)


# avy-more-links

Small library for adding and removing advice to functions.

## Installation

<!-- ### MELPA -->

<!-- Symbol’s value as variable is void: $1 is available from MELPA (both -->
<!-- [stable](http://stable.melpa.org/#/avy-more-links) and -->
<!-- [unstable](http://melpa.org/#/avy-more-links)).  Assuming your -->
<!-- ((melpa . https://melpa.org/packages/) (gnu . http://elpa.gnu.org/packages/) (org . http://orgmode.org/elpa/)) lists MELPA, just type -->

<!-- ~~~sh -->
<!-- M-x package-install RET avy-more-links RET -->
<!-- ~~~ -->

<!-- to install it. -->

### Quelpa

Using [use-package](https://github.com/jwiegley/use-package) with [quelpa](https://github.com/quelpa/quelpa).

~~~elisp
(use-package
:quelpa ((avy-more-links
:fetcher github
:repo "lordpretzel/avy-more-links")
:upgrade t)
)
~~~

### straight

Using [use-package](https://github.com/jwiegley/use-package) with [straight.el](https://github.com/raxod502/straight.el)

~~~elisp
(use-package avy-more-links
:straight (avy-more-links :type git :host github :repo "lordpretzel/avy-more-links")
~~~

### Source

Alternatively, install from source. First, clone the source code:

~~~sh
cd MY-PATH
git clone https://github.com/lordpretzel/avy-more-links.git
~~~

Now, from Emacs execute:

~~~
M-x package-install-file RET MY-PATH/avy-more-links
~~~

Alternatively to the second step, add this to your Symbol’s value as variable is void: \.emacs file:

~~~elisp
(add-to-list 'load-path "MY-PATH/avy-more-links")
(require 'avy-more-links)
~~~
