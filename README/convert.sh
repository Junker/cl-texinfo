sbcl --no-sysinit --no-userinit --script ./readme.lisp
texi2any --docbook --no-split -o - /tmp/texinfo-readme.texi | pandoc -f docbook -t markdown > ../README.md
