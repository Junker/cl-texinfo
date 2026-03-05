(load "../.qlot/setup.lisp")
(ql:quickload :alexandria)
(load "../texinfo.lisp")
(in-package :texinfo)


(defmacro @example-escaped (() &body body)
  `(@example ()
             ,@(mapcar (lambda (str)
                         `(strcat (escape ,str) nl))
                       body)))

(defmacro @lisp-escaped (() &body body)
  `(@lisp ()
          ,@(mapcar (lambda (str)
                      `(strcat (escape ,str) nl))
                    body)))

(defmacro @itemn (&rest args)
  `(@item (strcat ,@args)))

(defvar *temp-file* "/tmp/texinfo-readme.texi")

(when (uiop:file-exists-p *temp-file*)
  (delete-file *temp-file*))

(texinfo-to-file (*temp-file*)
  (@setfilename "readme.info")
  (@settitle "cl-texinfo: A Common Lisp Library for Generating Texinfo")

  (@copying ()
            "This manual is for cl-texinfo, a Common Lisp library for generating
Texinfo documentation.")

  (@titlepage ()
    (@title "cl-texinfo")
    (@subtitle "A Common Lisp Library for Generating Texinfo"))

  (@contents)

  (@node "Top" "Description")
  (@top "cl-texinfo")

  (@node "CL-TEXINFO" "Getting Started")
  (@chapter "CL-TEXINFO")

  "cl-texinfo is a Common Lisp library that provides utilities for generating
Texinfo documentation programmatically. It offers macros and functions that
mirror Texinfo commands, making it easy to write documentation from within
Lisp code."
  nl

  (@node "Getting Started" "Escaping Text" "Introduction" "Top")
  (@chapter "Getting Started")

  (@section "Installation")

  "Load cl-texinfo in your Lisp image:" nl

  (@example-escaped ()
    "(ql-dist:install-dist \"http://dist.ultralisp.org/\"
                          :prompt nil)"
    "(ql:quickload :texinfo)")

  (@section "Basic Usage")

  "The library exports functions and macros corresponding to Texinfo commands.
Each command returns a string containing the generated Texinfo markup." nl

  (@example-escaped ()
    "(@chapter \"Introduction\")")

  "This produces:" nl

  (@example-escaped ()
    "@chapter Introduction")

  (@section "A Complete Example")

  "Here is a simple example that generates a complete Texinfo document:" nl

  (@lisp-escaped ()
    "(texinfo"
    "  (@settitle \"My Document\")"
    "  (@setfilename \"my-document.info\")"
    "  (@node \"Top\" \"Chapter 1\" nil nil)"
    "  (@top \"My Document\")"
    "  (@chapter \"Introduction\")"
    "  \"This is the first chapter.\")")

  (@section "Line Commands")

  "Line commands produce output on a single line:" nl

  (@lisp-escaped ()
    "(@chapter \"Introduction\")"
    ";; => \"@chapter Introduction\""
    ""
    "(@c \"This is a comment\")"
    ";; => \"@c This is a comment\"")

  (@section "Braced Commands")

  "Braced commands wrap arguments in braces:" nl

  (@lisp-escaped ()
    "(@code \"example\")"
    ";; => \"@code{example}\""
    ""
    "(@emph \"important text\")"
    ";; => \"@emph{important text}\"")

  "Multiple arguments are separated by commas:" nl

  (@lisp-escaped ()
    "(@xref \"Introduction\" \"see Introduction\")"
    ";; => \"@xref{Introduction, see Introduction}\"")

  (@section "Block Commands")

  "Block commands create environments that span multiple lines:" nl

  (@lisp-escaped ()
    "(@example ()"
    "  (@code \"line 1\")"
    "  (@code \"line 2\"))")

  (@node "Document Structure" "Text Formatting" "Getting Started" "Top")
  (@chapter "Document Structure")

  (@section "Creating Nodes")

  "Nodes are the fundamental navigation units in Texinfo:" nl

  (@lisp-escaped ()
    "(@node \"Chapter One\" \"Chapter Two\" \"Top\" \"Top\")"
    "(@chapter \"First Chapter\")")

  "The " (@code "@node") " function accepts up to four arguments:" nl

  (@table ("@code")
    (@item "name")
    "The node name (required)"
    (@item "next")
    "The next node in sequence"
    (@item "previous")
    "The previous node"
    (@item "up")
    "The parent node")

  (@section "Chapter and Section Commands")

  "Use chapter and section commands to structure your document:" nl

  (@lisp-escaped ()
    "(@chapter \"Main Topic\")"
    "(@section \"Subtopic\")"
    "(@subsection \"Detail\")"
    "(@subsubsection \"Fine Detail\")")

  (@section "Menus")

  "Menus provide navigation within Info readers:" nl

  (@lisp-escaped ()
    "(@menu nil"
    "  (menu-entry \"Chapter 1\" \"chap1\" \"Introduction\")"
    "  (menu-entry \"Chapter 2\" \"chap2\" \"Advanced Topics\"))")

  (@node "Text Formatting" "Cross References" "Document Structure" "Top")
  (@chapter "Text Formatting")

  (@section "Emphasis")

  (@lisp-escaped ()
    "(@emph \"emphasized text\")"
    "(@strong \"strong emphasis\")"
    "(@b \"bold text\")"
    "(@i \"italic text\")")

  (@section "Code and Samples")

  (@lisp-escaped ()
    "(@code \"symbol-name\")"
    "(@samp \"sample text\")"
    "(@var \"variable\")"
    "(@file \"filename.lisp\")"
    "(@command \"ls -la\")"
    "(@option \"--verbose\")")

  (@section "Quotations and Examples")

  "Use block commands for longer passages:" nl

  (@lisp-escaped ()
    "(@quotation ()"
    "  \"This is a quoted passage.\")"
    "(@example ()"
    "  (@code \"(defun hello ()\")"
    "  (@code \"  (print \\\"Hello, World!\\\"))\"))")

  (@node "Cross References" "Lists and Tables" "Text Formatting" "Top")
  (@chapter "Cross References")

  (@section "Within a Document")

  (@lisp-escaped ()
    "(@xref \"Node Name\" \"display text\")"
    "(@ref \"Node Name\" \"display text\")"
    "(@anchor \"anchor-name\")")

  (@section "External References")

  (@lisp-escaped ()
    "(@url \"https://example.com\")"
    "(@uref \"https://example.com\" \"Example Site\")"
    "(@inforef \"Node Name\" \"text\" \"manual-name\")")

  (@node "Lists and Tables" "Definition Commands" "Cross References" "Top")
  (@chapter "Lists and Tables")

  (@section "Itemize Lists")

  (@lisp-escaped ()
    "(@itemize ((@bullet))"
    "  (@item \"First item\")"
    "  (@item \"Second item\")"
    "  (@item \"Third item\"))")

  (@section "Enumerated Lists")

  (@lisp-escaped ()
    "(@enumerate (1)"
    "  (@item \"Step one\")"
    "  (@item \"Step two\")"
    "  (@item \"Step three\"))")

  (@section "Tables")

  (@lisp-escaped ()
    "(@table (@code)"
    "  (@item \"car\")"
    "  \"Returns the first element of a list.\""
    "  (@itemx \"cdr\")"
    "  \"Returns the rest of a list.\")")

  (@node "Definition Commands" "Rendering Output" "Lists and Tables" "Top")
  (@chapter "Definition Commands")

  "Texinfo provides specialized commands for documenting code:" nl

  (@section "Variables")

  (@lisp-escaped ()
    "(@defvar \"*standard-input*\")")

  (@section "Functions")

  (@lisp-escaped ()
    "(@deffn \"Function\" \"format\" \"stream control-string &rest arguments\")"
    "\"Outputs formatted text to STREAM.\"")

  "The library provides predefined definition commands:" nl

  (@itemize ((@bullet))
    (@itemn (@code "@defvar") ", " (@code "@defopt") " - Variable definitions")
    (@itemn (@code "@deftypevar") " - Typed variable definitions")
    (@itemn (@code "@deffn") ", " (@code "@deftypefn") " - Function definitions")
    (@itemn (@code "@defmacro") " - Macro definitions")
    (@itemn (@code "@defvr") ", " (@code "@deftypevr") " - Generic definitions"))

  (@node "Rendering Output" "API Reference" "Definition Commands" "Top")
  (@chapter "Rendering Output")

  (@section "String Output")

  "Use " (@code "texinfo") " to generate a string:" nl

  (@lisp-escaped ()
    "(texinfo"
    "  (@settitle \"Document\")"
    "  (@chapter \"Content\"))")

  (@section "File Output")

  "Use " (@code "texinfo-to-file") " to write directly to a file:" nl

  (@lisp-escaped ()
    "(texinfo-to-file (#p\"output.texi\")"
    "  (@settitle \"My Document\")"
    "  (@chapter \"Introduction\"))"))
