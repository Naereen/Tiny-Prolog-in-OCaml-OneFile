# Makefile to build https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile
# (C) 2020 Lilian Besson
# MIT License, https://lbesson.mit-license.org/

main:	prolog

prolog:	prolog.ml
	ocamlc -o prolog -pp camlp4o prolog.ml
	# ocamlc -o prolog prolog.ml

prolog_no_camlp4o:	prolog.ml
	camlp4o -impl prolog.ml -o prolog_after_camlp4o.ml
	file prolog_after_camlp4o.ml
	ocamlc -o prolog_no_camlp4o.exe prolog_after_camlp4o.ml

prolog.opt:	prolog.ml
	ocamlopt -o prolog.opt -pp camlp4o prolog.ml
	# ocamlopt -o prolog.opt prolog.ml

clean:
	rm -vf ./*.cm[iox] ./*.annot ./*.o

cleanbuild:
	rm -vf ./prolog ./prolog.opt
