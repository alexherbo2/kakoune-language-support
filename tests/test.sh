log_path=$(mktemp)
at_exit() {
  rm -f "$log_path"
}
trap at_exit EXIT

kak -n -ui dummy -e "source tests/util.kak $log_path; source tests/init.kak; goodbye"
exit_code=$?
cat "$log_path"
exit "$exit_code"
