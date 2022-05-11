Kaitai Struct parser for Dirtywave M8 file formats

<!-- vim-markdown-toc GFM -->

* [Overview](#overview)
* [Development](#development)
* [Credits](#credits)

<!-- vim-markdown-toc -->

## Overview

This repository contains [Kaitai Struct][ks] `.ksy` definitions to parse
various binary file formats used by the [Dirtywave M8][m8].  So far it includes
initial support for:

* `.m8s` Song files
* `.m8i` Instrument files
* `.m8t` Theme files
* `.m8n` Scale files

These Kaitai Struct definitions can be compiled into ready-made format handling
libraries in various languages (C++/STL, C#, Go , Java , JavaScript , Lua, Nim,
Perl, PHP, Python, Ruby).

## Development

* Open the [Kaitai Struct IDE][kside] and load `m8s.ksy`, experiment with your
  own files!

## Credits

* Thanks to [Dirtywave](https://github.com/Dirtywave) for creating the M8!
* Thanks to [ftsf](https://github.com/ftsf) for [reversing and documenting most
  of the M8 binary
  formats](https://gist.github.com/ftsf/223b0fc761339b3c23dda7dd891514d9) and
  making various M8 tools, like [matey]).  It was a great introduction to
  [nim], too!


[m8]: https://dirtywave.com/
[kside]: https://ide.kaitai.io/#
[ks]: https://kaitai.io/
[matey]: https://www.impbox.net/matey/
[nim]: https://nim-lang.org/
