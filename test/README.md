# Testing Kakoune scripts

A basic test looks something like this:

``` kak
test 'Select words' %{

  init %{
    execute-keys 's\w+<ret>'
  }

  set-input %[
    [Hello, World!]
  ]

  set-output %[
    [Hello], [World]!
  ]
}
```

Text enclosed in square brackets `[]` denotes selected text.

## Running tests

``` sh
make test
```

Tests live in the `test` directory and must end with `_test.kak`.
