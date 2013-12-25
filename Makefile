prefix=/usr

life: life.c
	$(CC) life.c -ansi -o life

.PHONY: clean install uninstall

clean:
	rm life.o life

install: life
	cp life $(prefix)/bin

uninstall:
	rm $(prefix)/bin/life
