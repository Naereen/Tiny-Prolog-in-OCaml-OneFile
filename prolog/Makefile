# Makefile to build https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile
# (C) 2020 Lilian Besson
# MIT License, https://lbesson.mit-license.org/

main:	prolog

prolog:	prolog.ml
	ocamlc -o prolog -pp camlp4o prolog.ml

prolog.opt:	prolog.ml
	ocamlopt -o prolog.opt-pp camlp4o prolog.ml

clean:
	rm -f *.cm[iox] *~ *.annot *.o

cleanbuild:
	prolog prolog.opt
