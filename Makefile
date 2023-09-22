CL65 = cl65
C1541 = c1541
XVIC = xvic

all: main main.d64

run: clean main main.d64
	$(XVIC) main.d64

main.d64: bin/main.prg
	$(C1541) -format "main,96" d64 $@
	$(C1541) $@ -write $< main
	$(C1541) $@ -list

main: src/main.s
	mkdir -p bin
	$(CL65) -d -g -Ln bin/$@.sim -o bin/$@.prg -t vic20 -C main.cfg $^

clean:
	rm -f main.d64
	rm -f bin/*.prg
