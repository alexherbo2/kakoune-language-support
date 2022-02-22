source rc/comment.kak

define-command write-append -params 1 %{
  evaluate-commands -draft %{
    execute-keys '%'
    nop %sh(printf '%s\n' "$kak_selection" >> "$1")
  }
}

define-command echo-to-file-append -params 2 %{
  nop %sh(printf '%s\n' "$2" >> "$1")
}

set-option buffer line_comment_token '#'
set-option buffer block_comment_tokens '=begin' '=end'

edit tests/assets/sample.cr
select 1.1,10.3
toggle-comments
echo-to-file-append tests/output.txt "%val{selections_desc}"
write-append tests/output.txt
edit!
quit!
