# Run tests and exit.

# Kakoune has started.
# Clear debug buffer.
delete-buffer '*debug*'

# Internal variables
declare-option str commands
declare-option str actual_output
declare-option str expected_output

declare-option int example_count 0
declare-option int failure_count 0
declare-option int error_count 0

declare-option int exit_code 0
declare-option str log_path %arg{1}

define-command test -params 2 %{
  set-option -add global example_count 1
  edit -scratch
  evaluate-commands %arg{2}

  # Indented strings
  # Leading whitespace is removed from the string contents
  # according to the number of whitespace in the last line before the string delimiter.
  # https://crystal-lang.org/reference/master/syntax_and_semantics/literals/string.html#heredoc
  set-register a %opt{actual_output}
  set-register b %opt{expected_output}
  execute-keys '%"aRs\A\n|\n\z<ret>d%1s(\h+)\n\z<ret>y%s^\Q<c-r>"<ret>dged%"ay'
  execute-keys '%"bRs\A\n|\n\z<ret>d%1s(\h+)\n\z<ret>y%s^\Q<c-r>"<ret>dged%"by'
  set-option global actual_output %reg{a}
  set-option global expected_output %reg{b}

  try %{
    # Map scratch buffer with original input.
    # Set buffer content and selected text from marks: [selected_text].
    execute-keys '%"aRs\[<ret><a-i>ri<backspace><esc>a<del><esc>'
    # Yields commands
    evaluate-commands %opt{commands}
    # Mark selected text: [selected_text].
    execute-keys 'i[<esc>a]<esc>%"ay'
    set-option global actual_output %reg{a}

    # assert_eq!
    # Asserts that two buffers are equal to each other (using buffer content and selection state).
    try %sh[ [ "$kak_opt_actual_output" = "$kak_opt_expected_output" ] || echo fail ] catch %{
      echo -debug "Failed example: %arg{1}"
      echo -debug 'Expected:'
      echo -debug "%opt{expected_output}"
      echo -debug 'Got:'
      echo -debug "%opt{actual_output}"
      set-option -add global failure_count 1
      set-option global exit_code 1
    }
  } catch %{
    echo -debug "Error: %val{error}"
    set-option -add global error_count 1
    set-option global exit_code 1
  }
  delete-buffer
}

define-command init -params 1 %{
  set-option global commands %arg{1}
}

define-command set-input -params 1 %{
  set-option global actual_output %arg{1}
}

define-command set-output -params 1 %{
  set-option global expected_output %arg{1}
}

# Run tests
# Source `test/**/*_test.kak`.
evaluate-commands %sh{
  find test -type f -name '*_test.kak' -exec printf 'source "%s";' {} +
}

# Print result and exit.
echo -debug "Result: %opt{example_count} examples, %opt{failure_count} failures, %opt{error_count} errors."
buffer '*debug*'
write! %opt{log_path}
quit! %opt{exit_code}
