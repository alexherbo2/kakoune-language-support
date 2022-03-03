build:

test:
	kak-test

install:
	install -d ~/.config/kak/autoload
	install rc/comment.kak rc/indent.kak ~/.config/kak/autoload

uninstall:
	rm -f ~/.config/kak/autoload/comment.kak ~/.config/kak/autoload/indent.kak

.PHONY: test
