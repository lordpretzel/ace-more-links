[![License: GPL 3](https://img.shields.io/badge/license-GPL_3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.txt)
<!-- [![GitHub release](https://img.shields.io/github/release/lordpretzel/ace-more-links.svg?maxAge=86400)](https://github.com/lordpretzel/ace-more-links/releases) -->
<!-- [![MELPA Stable](http://stable.melpa.org/packages/ace-more-links-badge.svg)](http://stable.melpa.org/#/ace-more-links) -->
<!-- [![MELPA](http://melpa.org/packages/ace-more-links-badge.svg)](http://melpa.org/#/ace-more-links) -->
[![Build Status](https://secure.travis-ci.org/lordpretzel/ace-more-links.png)](http://travis-ci.org/lordpretzel/ace-more-links)


# ace-more-links

Small library for adding and removing advice to functions.

## Installation

<!-- ### MELPA -->

<!-- Symbol’s value as variable is void: $1 is available from MELPA (both -->
<!-- [stable](http://stable.melpa.org/#/ace-more-links) and -->
<!-- [unstable](http://melpa.org/#/ace-more-links)).  Assuming your -->
<!-- ((melpa . https://melpa.org/packages/) (gnu . http://elpa.gnu.org/packages/) (org . http://orgmode.org/elpa/)) lists MELPA, just type -->

<!-- ~~~sh -->
<!-- M-x package-install RET ace-more-links RET -->
<!-- ~~~ -->

<!-- to install it. -->

### Quelpa

Using [use-package](https://github.com/jwiegley/use-package) with [quelpa](https://github.com/quelpa/quelpa).

~~~elisp
(use-package
:quelpa ((ace-more-links
:fetcher github
:repo "lordpretzel/ace-more-links")
:upgrade t)
)
~~~

### straight

Using [use-package](https://github.com/jwiegley/use-package) with [straight.el](https://github.com/raxod502/straight.el)

~~~elisp
(use-package ace-more-links
:straight (ace-more-links :type git :host github :repo "lordpretzel/ace-more-links")
~~~

### Source

Alternatively, install from source. First, clone the source code:

~~~sh
cd MY-PATH
git clone https://github.com/lordpretzel/ace-more-links.git
~~~

Now, from Emacs execute:

~~~
M-x package-install-file RET MY-PATH/ace-more-links
~~~

Alternatively to the second step, add this to your Symbol’s value as variable is void: \.emacs file:

~~~elisp
(add-to-list 'load-path "MY-PATH/ace-more-links")
(require 'ace-more-links)
~~~
