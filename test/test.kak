# Run tests and exit.

# Kakoune has started.
# Clear debug buffer.
delete-buffer '*debug*'

# Internal variables
declare-option str actual_output
declare-option str expected_output

declare-option str-list tests

# Reference:
# <https://github.com/crystal-lang/crystal/blob/master/src/spec/context.cr#:~:text=enum Status>
declare-option int test_count 0
declare-option int success_count 0
declare-option int failure_count 0
declare-option int error_count 0

declare-option str final_status_message
declare-option int exit_code 0
declare-option str log_path %arg{1}

declare-option str tmp %sh(mktemp -d)

hook -always global KakEnd '' %{
  nop %sh(rm -Rf "$kak_opt_tmp")
}

# Commands

# Creates a buffer from the given string.
#
# Syntax
#
# create_buffer_from_string <buffer_name> <text>
#
# Reference:
#
# https://github.com/mawww/kakoune/blob/master/src/buffer_utils.cc#:~:text=create_buffer_from_string
#
define-command -override create_buffer_from_string -params 2 %{
  edit -scratch %arg{1}
  set-register dquote %arg{2}
  execute-keys '%R'
}

# Indented strings
#
# Leading whitespace is removed from the string contents according to the number of whitespace in the last line before the string delimiter.
#
# Syntax
#
# create_buffer_from_template_string <buffer_name> <template_text>
#
# Reference:
#
# - <https://nixos.org/manual/nix/stable/expressions/language-values.html#:~:text=indented string>
# - https://crystal-lang.org/reference/master/syntax_and_semantics/literals/string.html#heredoc
#
define-command create_buffer_from_template_string -params 2 %{
  create_buffer_from_string %arg{1} %arg{2}
  execute-keys '%s\A\n|\n\z<ret>d%1s(\h+)\n\z<ret>y%s^\Q<c-r>"<ret>dged%s\[<ret><a-i>ri<backspace><esc>a<del><esc>'
}

# Reference:
#
# - https://doc.rust-lang.org/std/macro.assert.html
# - https://doc.rust-lang.org/std/macro.assert_eq.html
#
define-command assert_eq -params 2 %{
}

# Asserts that two buffers are equal to each other.
# Buffer contents and selected text should be equal.
define-command assert_buffer_eq -params 2 %{
  set-register a "%opt{tmp}/a"
  set-register b "%opt{tmp}/b"
  buffer %arg{1}
  set-register c %val{selections_desc}
  write! %reg{a}
  buffer %arg{2}
  set-register d %val{selections_desc}
  write! %reg{b}

  # Asserts that two buffers are equal to each other.
  # Buffer contents and selected text should be equal.
  try %sh[ cmp -s "$kak_reg_a" "$kak_reg_b" && test "$kak_reg_c" = "$kak_reg_d" || echo fail ] catch %{
    # Failure message
    # Mark selected text
    # Text enclosed in square brackets `[]` denotes selected text.
    edit %reg{a}
    select %reg{c}
    execute-keys 'i[<esc>a]<esc>'
    write

    edit %reg{b}
    select %reg{d}
    execute-keys 'i[<esc>a]<esc>'
    write

    echo -debug "Expected:"
    evaluate-commands "echo -debug %%file{%reg{a}}"
    echo -debug "Got:"
    evaluate-commands "echo -debug %%file{%reg{b}}"

    # Return status
    fail fail
  }
}

# Syntax:
#
# test <description> <commands>
#
# Reference:
# - https://github.com/crystal-lang/crystal/blob/master/src/spec/context.cr
# - https://github.com/crystal-lang/crystal/blob/master/src/spec/expectations.cr
define-command add_test -params 2 %{
  define-command %arg{1} %arg{2}
  set-option -add global tests %arg{1}
  set-option -add global test_count 1
}

# https://doc.rust-lang.org/test/fn.run_tests.html
define-command run_tests %{
  evaluate-commands %sh{
    eval set -- "$kak_opt_tests"
    echo "echo running $# tests"
    for test do
      echo "run_test $test"
    done
  }
}

# https://doc.rust-lang.org/test/fn.run_test.html
define-command run_test -params 1 %{
  echo -debug "test %arg{1}"
  edit -scratch '*test*'
  try %{
    # Yields commands
    evaluate-commands %arg{1}
    set-option -add global success_count 1
  } catch %{
    # Rescue `fail` status.
    try %{
      evaluate-commands %sh[ [ "$kak_error" = fail ] || echo fail ]
      set-option -add global failure_count 1
    } catch %{
      echo -debug "Error: %val{error}"
      set-option -add global error_count 1
    }
  }
  delete-buffer '*test*'
}

# Aliases
alias global test add_test
alias global buffer_str create_buffer_from_string
alias global buffer_str! create_buffer_from_template_string

# Run tests
# Source `test/**/*_test.kak`.
evaluate-commands %sh{
  find test -type f -name '*_test.kak' -exec printf 'source "%s";' {} +
}

# Run tests
run_tests

# Print result and exit.
evaluate-commands %sh{
  if [ "$kak_opt_failure_count" -gt 0 ] || [ "$kak_opt_error_count" -gt 0 ]; then
    echo 'set-option global exit_code 1'
    echo 'set-option global final_status_message "not ok"'
  else
    echo 'set-option global final_status_message "ok"'
  fi
}
# final_status_message
echo -debug "test result: %opt{final_status_message}. %opt{success_count} passed, %opt{failure_count} failed, %opt{error_count} panicked."
buffer '*debug*'
write! %opt{log_path}
quit! %opt{exit_code}
