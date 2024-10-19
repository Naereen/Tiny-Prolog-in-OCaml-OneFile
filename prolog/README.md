# This folder contains the source code of [Tiny-Prolog-in-OCaml-OneFile](https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile)
> A tiny implementation of a small subset of the Prolog language, in OCaml. With small and fun examples.
>
> WARNING: this project only has an **educational purpose**, for a real-world use of Prolog, please refer to [GNU Prolog (gprolog)](XXX).

## Requirements
- Have [OCaml 4.14+](https://ocaml.org/) installed, with [camlp4o](https://ocaml.org/p/camlp4/4.14%2B1) (install it with `opam install camlp4`);
- And GNU Makefile.

## How to build
- Clone or download the repository (`git clone https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile/`),
- Go in this folder (`cd Tiny-Prolog-in-OCaml-OneFile/`),
- Run `make`, wait 5 seconds, and :tada: tadaa!

```bash
$ cd /tmp/
$ git clone https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile
$ cd Tiny-Prolog-in-OCaml-OneFile
$ cd prolog
$ make prolog
ocamlc -o prolog -pp camlp4o prolog.ml
$ make clean
$ file prolog
prolog: a ocamlrun script executable (binary data)
```

- If you need a native binary, do `make prolog.opt` instead.

## List of files
- [Makefile](Makefile) defines the rules to build the binary,
- [`prolog.ml`](prolog.ml) implements (manually) the command line binary (parse input, etc), useful functions, and the data structure to manipulate terms, the parsing of a theory file, and the resolution algorithm to answer logical questions on a 0th-order theory.

---

## How to use `prolog`
- Load a theory (`.pl` file), and ask a question:
```bash
$ ./prolog theory.pl
?- ... # ask your question, end with .
```

- Or load a theory and ask a question, directly from the command line:
```bash
$ ./prolog theory.pl "question(...,...)."
?- ... # give the answer, and quit
```

## How to test
- Use one of the [examples](../examples/):

```bash
cd ..
cd exemples
../prolog/prolog ./pair.pl "pair(o)."  # load a theory and ask a question
../prolog/prolog ./impair.pl "impair(o)."  # load a theory and ask a question
../prolog/prolog ./famille.pl "ancetre(X,renaud)."  # load a theory and ask a question
```

---

### :scroll: License ? [![GitHub license](https://img.shields.io/github/license/Naereen/Tiny-Prolog-in-OCaml-OneFile.svg)](https://github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile/blob/master/LICENSE)
This (small) repository is published under the terms of the [MIT license](http://lbesson.mit-license.org/) (file [LICENSE](LICENSE)).
© [Lilian Besson](https://GitHub.com/Naereen), 2018-2024.

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/Tiny-Prolog-in-OCaml-OneFile/graphs/commit-activity)
[![Ask Me Anything !](https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg)](https://GitHub.com/Naereen/Tiny-Prolog-in-OCaml-OneFile)
[![Analytics](https://ga-beacon.appspot.com/UA-38514290-17/github.com/Naereen/Tiny-Prolog-in-OCaml-OneFile/README.md?pixel)](https://GitHub.com/Naereen/Tiny-Prolog-in-OCaml-OneFile/)

[![made-with-OCaml](https://img.shields.io/badge/Made%20with-OCaml-1f425f.svg)](https://ocaml.org/)
[![made-for-teaching](https://img.shields.io/badge/Made%20for-Teaching-6800ff.svg)](https://perso.crans.org/besson/teach/)

[![ForTheBadge built-with-science](http://ForTheBadge.com/images/badges/built-with-science.svg)](https://GitHub.com/Naereen/)
[![ForTheBadge uses-badges](http://ForTheBadge.com/images/badges/uses-badges.svg)](http://ForTheBadge.com)
[![ForTheBadge uses-git](http://ForTheBadge.com/images/badges/uses-git.svg)](https://GitHub.com/)
