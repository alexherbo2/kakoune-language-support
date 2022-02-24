declare-option int example_count
declare-option int failure_count
declare-option int error_count
declare-option int exit_code
declare-option str log_path %arg{1}

# Syntax:
#
# tests <commands>
#
define-command tests -params 1 %{
  delete-buffer '*debug*'
  evaluate-commands %arg{1}
  echo -debug "Result: %opt{example_count} examples, %opt{failure_count} failures, %opt{error_count} errors."
  buffer '*debug*'
  write! %opt{log_path}
  quit! %opt{exit_code}
}

# Syntax:
#
# test <description> <commands> <input> <output>
#
define-command test -params 4 %{
  edit -scratch
  # https://crystal-lang.org/reference/master/syntax_and_semantics/literals/string.html#heredoc
  set-register a %arg{3}
  set-register b %arg{4}
  execute-keys '%"aR%<s>\A\n|\n\z<ret>d%1<s>(\h*)\n\z<ret>y%<s>^\Q<c-r>"<ret>dged%"ay'
  execute-keys '%"bR%<s>\A\n|\n\z<ret>d%1<s>(\h*)\n\z<ret>y%<s>^\Q<c-r>"<ret>dged%"by'
  set-option -add global example_count 1
  # Map scratch buffer with register A.
  try %{
    # Set buffer content and selected text from marks: [selected_text].
    execute-keys '"aR<s>\[<ret><a-i>ri<backspace><esc>a<del><esc>'
    # Yields commands
    evaluate-commands %arg{2}
    # Mark selected text: [selected_text].
    execute-keys 'i[<esc>a]<esc>%"ay'

    # assert_eq!
    # Asserts that two buffers are equal to each other (using buffer content and selection state).
    try %sh[ [ "$kak_reg_a" = "$kak_reg_b" ] || echo fail ] catch %{
      echo -debug "Failed example: %arg{1}"
      echo -debug 'Expected:'
      echo -debug "%reg{b}"
      echo -debug 'Got:'
      echo -debug "%reg{a}"
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
