at_exit() {
  rm -f tests/output.txt
}
trap at_exit EXIT

kak -n -e 'source tests/init.kak'
diff -u tests/output.txt tests/comment/expected-output.txt
