at_exit() {
  rm -f tests/output.txt
}
trap at_exit EXIT

kak -n -ui dummy -e 'source tests/init.kak'
diff -u tests/output.txt tests/expected-output.txt
