# This script provides the functionality to test Kakoune scripts.
# Tests live in the `test` directory and must end with `_test.kak`.

tmp=$(mktemp -d)
log_path=$tmp/kakoune.log
at_exit() {
  rm -Rf "$tmp"
}
trap at_exit EXIT

kak -n -ui dummy -e "source test/test.kak $log_path" < /dev/null > /dev/null 2>&1 &
kak_pid=$!
wait "$kak_pid"
exit_code=$?
cat "$log_path"
exit "$exit_code"
