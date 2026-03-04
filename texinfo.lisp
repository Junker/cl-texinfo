(defpackage texinfo
  (:use #:cl
        #:alexandria)
  (:import-from #:uiop
                #:strcat
                #:reduce/strcat)
  (:export #:texinfo
           #:texinfo-to-file
           #:@menu
           #:menu-entry
           #:@node
           #:escape
           #:nl))

(in-package :texinfo)

;; ==========================================================================
;; Escaping
;; ==========================================================================

(defvar *special-characters*
  '((#\@ . "atchar")
    (#\{ . "lbracechar")
    (#\} . "rbracechar")
    (#\, . "comma")
    (#\\ . "backslashchar")
    (#\# . "hashchar")
    (#\& . "ampchar"))
  "An association list of Texinfo special characters.
Elements are the form (CHAR . COMMAND) where CHAR is the special character and
COMMAND is the name of the corresponding Texinfo alphabetic command.")

(defun escape (string)
  "When STRING, escape it for Texinfo."
  (when string
    (with-output-to-string (s)
      (loop :for char :across string
            :do (if-let ((special (assoc-value *special-characters* char)))
                  (write-string (strcat "@" special "{}") s)
                  (write-char char s))))))

(defun escape-newline (string)
  "When STRING, escape newline for Texinfo."
  (when string
    (substitute #\Space #\Newline string)))

(defun escape-comma (string)
  "When STRING, escape comma for Texinfo."
  (when string
    (with-output-to-string (s)
      (loop :for char :across string
            :do (if (eq char #\,)
                    (write-string "@comma{}" s)
                    (write-char char s))))))


;; ==========================================================================
;; ==========================================================================

(defvar nl (string #\Newline))

(defun @end (environment)
  "Render and @end ENVIRONMENT line on *standard-output*.
ENVIRONMENT should be a string designator."
  (format nil "~&@end ~(~A~)~%" environment))

(defun command-string (sym)
  (string-downcase (symbol-name sym)))

(defmacro define-command (command args &body body)
  `(progn
     (export ',command)
     (defun ,command ,args
       ,@body)))

(defun prepare-command-argument (arg)
  (princ-to-string arg))

(defmacro define-line-command (command args &key (escape nil))
  (multiple-value-bind (req-args opt-args rest-args)
      (parse-ordinary-lambda-list args)
    `(define-command ,command ,args
       ,(format nil "Render an ~A line." command)
       ,(if (not args)
            (strcat (command-string command) "~%")
            `(format nil ,(strcat (command-string command) " ~{~A~^ ~}~%")
                     (mapcar (compose ,(if escape
                                           `(compose #'escape #'escape-newline)
                                           `#'escape-newline)
                                      #'prepare-command-argument)
                             (append (list ,@req-args ,@(mapcar #'car opt-args))
                                     ,rest-args)))))))

(defmacro define-braced-command (command args &key (escape t))
  (multiple-value-bind (req-args opt-args rest-args)
      (parse-ordinary-lambda-list args)
    `(define-command ,command ,args
       ,(format nil (strcat "Render ~A." (when escape "
arguments are escaped for Texinfo prior to rendering."))
                command)
       ,(if (not args)
            (strcat (command-string command) "{}")
            `(format nil ,(strcat (command-string command) "{~{~A~^, ~}}")
                     (mapcar (compose ,(if escape '#'escape '#'escape-comma)
                                      #'prepare-command-argument)
                             (remove nil (append (list ,@req-args ,@(mapcar #'car opt-args))
                                                 ,rest-args))))))))

(defmacro define-block-command (command args)
  (multiple-value-bind (req-args opt-args)
      (parse-ordinary-lambda-list args)
    (let* ((body (gensym "body"))
           (funname (symbolicate '% command))
           (opt-args (mapcar #'car opt-args))
           (prep-args (append req-args opt-args)))
      `(progn
         (defun ,funname (,@req-args ,@opt-args ,body)
           (strcat ,(command-string command) " "
                   (format nil "~{~A~^ ~}"
                           (mapcar #'prepare-command-argument
                                   (list ,@prep-args)))
                   nl
                   (reduce/strcat ,body)
                   nl
                   (@end ,(subseq (string command) 1))))
         (export ',command)
         (defmacro ,command ((,@args) &body body)
           ,(format nil "Render ~A." command)
           (let ((args (list ,@prep-args))
                 (funname ',funname))
             `(,funname ,@args (list ,@body))))))))

;; ==========================================================================
;; Comments
;; ==========================================================================
(define-line-command @c (comment))

;; ==========================================================================
;; Generating a Table of Contents
;; ==========================================================================
(define-line-command @contents ())
(define-line-command @shortcontents ())
(define-line-command @summarycontents ())

;; ==========================================================================
;; File Header
;; ==========================================================================
(define-line-command @settitle (title))
(define-line-command @setfilename (info-file-name))

;; ==========================================================================
;;  Document Permissions
;; ==========================================================================

(define-block-command @copying ())
(define-line-command @insertcopying ())

;; ==========================================================================
;; Title and Copyright Pages
;; ==========================================================================

(define-block-command @titlepage ())
(define-line-command @title (title))
(define-line-command @subtitle (title))
(define-line-command @author (author))
(define-braced-command @titlefont (text))
(define-line-command @center (line-of-text))
(define-line-command @sp (n))


;; ==========================================================================
;;  Menu
;; ==========================================================================

(defun menu-entry (node-name &optional entry-name description)
  (if entry-name
      (format nil "~&* ~A: ~A             ~(~A~)~%" entry-name node-name description)
      (format nil "~&* ~A::               ~(~A~)~%" node-name description)))

(defun @menu (comment &rest entries)
  (strcat (format nil "~&@menu~%")
          (when comment
            (format nil "~&~A~%" comment))
          (reduce/strcat entries)
          "~%@end menu"))

;; ==========================================================================
;; Nodes
;; ==========================================================================

(defun @node (name &optional next previous up)
  "Render an @node line on *standard-output*."
  (format nil "~&@node ~A~@[, ~A~]~@[, ~A~]~@[, ~A~]" name next previous up))

(define-line-command @top (title))

;; ==========================================================================
;; Chapter Structuring
;; ==========================================================================

(define-line-command @chapter (title))
(define-line-command @unnumbered (title))
(define-line-command @majorheading (title))
(define-line-command @chapheading (title))
(define-line-command @unnumberedsec (title))
(define-line-command @appendixsec (title))
(define-line-command @heading (title))
(define-line-command @subsection (title))
(define-line-command @subsubsection (title))
(define-line-command @unnumberedsubsec (title))
(define-line-command @appendixsubsec (title))
(define-line-command @subheading (title))
(define-line-command @section (title))

;; ==========================================================================
;; Cross-Referencing
;; ==========================================================================

(define-braced-command @anchor (name))
(define-braced-command @cite (reference))
(define-braced-command @xref (node-name &optional online-label printed-label
                                        manual-name printed-manual-title))
(define-braced-command @ref (node-name &optional online-label printed-label
                                       manual-name printed-manual-title))
(define-braced-command @link (node-name &optional label manual-name))
(define-braced-command @inforef (node-name &optional cross-reference-name info-file-name))
(define-braced-command @url (url &optional text replacement))
(define-braced-command @uref (url &optional text replacement))

;; ==========================================================================
;; Marking Text, Words and Phrases
;; ==========================================================================

(define-braced-command @code (sample-code))
(define-braced-command @key (key-name))
(define-braced-command @samp (text))
(define-braced-command @verb (text) :escape nil)
(define-braced-command @var (metasyntactic-variable))
(define-braced-command @env (environment-variable))
(define-braced-command @file (file-name))
(define-braced-command @command (command-name))
(define-braced-command @option (option))
(define-braced-command @dfn (term))
(define-braced-command @cite (reference))
(define-braced-command @abbr (abbreviation))
(define-braced-command @indicateurl (uniform-resource-locator))
(define-braced-command @acronym (text &optional meaning))
(define-braced-command @email (address &optional display-text))

(defun @kbd (arg1 &rest args)
  "Render @kbd"
  (format nil "@kbd{~A~{~A~^ ~}}" arg1 args))

;; ==========================================================================
;; Emphasizing Text
;; ==========================================================================

(define-braced-command @emph (text))
(define-braced-command @strong (text))
(define-braced-command @sc (text))
(define-line-command @fonttextsize (size))
(define-braced-command @b (text))
(define-braced-command @i (text))
(define-braced-command @r (text))
(define-braced-command @sansserif (text))
(define-braced-command @slanted (text))
(define-braced-command @t (text))

;; ==========================================================================
;; Quotations and Examples
;; ==========================================================================

(define-block-command @quotation ())
(define-block-command @indentedblock ())
(define-block-command @example ())
(define-block-command @lisp ())
(define-block-command @verbatim ())
(define-block-command @display ())
(define-block-command @format ())
(define-block-command @smallquotation ())
(define-block-command @smallindentedblock ())
(define-block-command @smallexample ())
(define-block-command @smalllisp ())
(define-block-command @smalldisplay ())
(define-block-command @smallformat ())
(define-block-command @flushleft ())
(define-block-command @flushright ())
(define-block-command @raggedright ())
(define-block-command @cartouche ())
(define-block-command @exdent ())
(define-block-command @noindent ())
(define-block-command @indent ())


;; ==========================================================================
;; Inserting Images
;; ==========================================================================
(define-braced-command @image (filename &optional width height alttext extension))

;; ==========================================================================
;; Footnotes
;; ==========================================================================
(define-braced-command @footnote (text))

;; ==========================================================================
;; Indices
;; ==========================================================================
(define-line-command @cindex (entry))
(define-line-command @findex (entry))
(define-line-command @kindex (entry))
(define-line-command @pindex (entry))
(define-line-command @tindex (entry))
(define-line-command @vindex (entry))
(define-line-command @printindex (abbr))
(define-line-command @defindex (index-name))

;; ==========================================================================
;; Inserting Accents
;; ==========================================================================
(define-braced-command @exclamdown ())
(define-braced-command @questiondown ())
(define-braced-command @aa ())
(define-braced-command @ae ())
(define-braced-command @dh ())
(define-braced-command @dotless (char))
(define-braced-command @l ())
(define-braced-command @o ())
(define-braced-command @oe ())
(define-braced-command @ordf ())
(define-braced-command @ss ())
(define-braced-command @th ())

;; ==========================================================================
;; Inserting Quotation Marks
;; ==========================================================================
(define-braced-command @quotedblleft ())
(define-braced-command @quotedblright ())
(define-braced-command @quoteleft ())
(define-braced-command @quoteright ())
(define-braced-command @quotedblbase ())
(define-braced-command @quotesinglbase ())
(define-braced-command @guillemetleft ())
(define-braced-command @guillemetright ())
(define-braced-command @guilsinglleft ())
(define-braced-command @guilsinglright ())

;; ==========================================================================
;; Inserting Subscripts and Superscripts
;; ==========================================================================
(define-braced-command @sub (text))
(define-braced-command @sup (text))

;; ==========================================================================
;; Glyphs for Text
;; ==========================================================================
(define-braced-command @copyright ())
(define-braced-command @registeredsymbol ())
(define-braced-command @dots ())
(define-braced-command @enddots ())
(define-braced-command @bullet ())
(define-braced-command @euro ())
(define-braced-command @pounds ())
(define-braced-command @textdegree ())
(define-braced-command @minus ())
(define-braced-command @geq ())

;; ==========================================================================
;; Conditionally Visible Text
;; ==========================================================================
(define-block-command @ifdocbook ())
(define-block-command @ifhtml ())
(define-block-command @iflatex ())
(define-block-command @ifplaintext ())
(define-block-command @iftex ())
(define-block-command @ifxml ())
(define-block-command @ifnotdocbook ())
(define-block-command @ifnothtml ())
(define-block-command @ifnotinfo ())
(define-block-command @ifnotlatex ())
(define-block-command @ifnotplaintext ())
(define-block-command @ifnottex ())
(define-block-command @ifnotxml ())
(define-block-command @ifdocbook ())
(define-block-command @ifdocbook ())
(define-block-command @ifdocbook ())
(define-block-command @ifdocbook ())

;; ==========================================================================
;; Inline Conditionals
;; ==========================================================================
(define-braced-command @inlinefmt (format text) :escape nil)
(define-braced-command @inlinefmtifelse (format then-text else-text) :escape nil)
(define-braced-command @inlineraw (format text) :escape nil)


;; ==========================================================================
;; Flags
;; ==========================================================================
(define-line-command @set (flag &optional value))
(define-line-command @clear (flag))
(define-line-command @ifset (flag))
(define-braced-command @inlineifset (flag text))
(define-line-command @ifclear (flag))
(define-braced-command @inlineifclear (flag text))
(define-braced-command @value (txivar))
;; ==========================================================================
;; Include Files
;; ==========================================================================
(define-line-command @include (filename))
(define-line-command @verbatiminclude (filename))

;; ==========================================================================
;; Lists and Tables
;; ==========================================================================
(define-line-command @item (&optional title))
(define-block-command @itemize (&optional mark-generating-character-or-command))
(define-block-command @enumerate (&optional number-or-letter))
(define-line-command @item ())
(define-line-command @itemx ())
(define-block-command @table (&optional formatting-command))
(define-block-command @vtable (&optional formatting-command))
(define-block-command @ftable (&optional formatting-command))



;; ==========================================================================
;; The Definition Commands
;; ==========================================================================

(define-block-command @defvr (category name))
(define-block-command @defvar (name))
(define-block-command @defopt (name))
(define-block-command @deftypevr (category data-type name))
(define-block-command @deftypevar (data-type name))
(define-block-command @defcv (category class name))
(define-block-command @deftypecv (category class data-type name))
(define-block-command @defivar (class name))
(define-block-command @deftypeivar (class data-type name))
(define-block-command @defblock ())

;; ==========================================================================
;; Rendering Utilities
;; ==========================================================================

(defun %texinfo (stream objects)
  (format stream "\\input texinfo~%")
  (dolist (obj objects)
    (write-string obj stream))
  (format stream "~&@bye"))

(defun texinfo (&rest objects)
  (with-output-to-string (s)
    (%texinfo s objects)))

(defun texinfo-to-file (file &rest objects)
  (with-output-to-file (s file)
    (%texinfo s objects)))
