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
