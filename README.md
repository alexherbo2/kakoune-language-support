# kakoune-language-support

This [Kakoune] extension allows you to define a language configuration that controls the following declarative language features.

[Kakoune]: https://kakoune.org

## Features

- Comment toggling
- Indentation rules

## Installation

Run the following in your terminal.

``` sh
git clone https://github.com/taupiqueur/kakoune-language-support.git
cd kakoune-language-support
make install
```

Alternatively, add [`comment.kak`] and [`indent.kak`] to your [`autoload`] directory.

[`comment.kak`]: rc/comment.kak
[`indent.kak`]: rc/indent.kak
[`autoload`]: https://github.com/mawww/kakoune#:~:text=autoload

## Documentation

See the [manual] for setup and usage instructions.

[Manual]: docs/manual.md
