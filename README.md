# CL-TEXINFO {#CL_002dTEXINFO}

cl-texinfo is a Common Lisp library that provides utilities for
generating Texinfo documentation programmatically. It offers macros and
functions that mirror Texinfo commands, making it easy to write
documentation from within Lisp code.

# Features {#Introduction}

-   Programmatic generation of Texinfo markup

-   Automatic escaping of special characters

-   Support for all major Texinfo commands

-   Macros for defining custom commands

-   Simple API for generating complete documents

# Getting Started {#Getting-Started}

## Installation

Load cl-texinfo in your Lisp image:

    (ql:quickload :texinfo)

## Basic Usage

The library exports functions and macros corresponding to Texinfo
commands. Each command returns a string containing the generated Texinfo
markup.

    (@chapter "Introduction")

This produces:

    @chapter Introduction

## A Complete Example

Here is a simple example that generates a complete Texinfo document:

    (texinfo
      (@settitle "My Document")
      (@setfilename "my-document.info")
      (@node "Top" "Chapter 1" nil nil)
      (@top "My Document")
      (@chapter "Introduction")
      "This is the first chapter.")

## Line Commands

Line commands produce output on a single line:

    (@chapter "Introduction")
    ;; => "@chapter Introduction"

    (@c "This is a comment")
    ;; => "@c This is a comment"

## Braced Commands

Braced commands wrap arguments in braces:

    (@code "example")
    ;; => "@code{example}"

    (@emph "important text")
    ;; => "@emph{important text}"

Multiple arguments are separated by commas:

    (@xref "Introduction" "see Introduction")
    ;; => "@xref{Introduction, see Introduction}"

## Block Commands

Block commands create environments that span multiple lines:

    (@example ()
      (@code "line 1")
      (@code "line 2"))

# Document Structure {#Document-Structure}

## Creating Nodes

Nodes are the fundamental navigation units in Texinfo:

    (@node "Chapter One" "Chapter Two" "Top" "Top")
    (@chapter "First Chapter")

The `@node` function accepts up to four arguments:

`name`

:   The node name (required)

`next`

:   The next node in sequence

`previous`

:   The previous node

`up`

:   The parent node

## Chapter and Section Commands

Use chapter and section commands to structure your document:

    (@chapter "Main Topic")
    (@section "Subtopic")
    (@subsection "Detail")
    (@subsubsection "Fine Detail")

## Menus

Menus provide navigation within Info readers:

    (@menu nil
      (menu-entry "Chapter 1" "chap1" "Introduction")
      (menu-entry "Chapter 2" "chap2" "Advanced Topics"))

# Text Formatting {#Text-Formatting}

## Emphasis

    (@emph "emphasized text")
    (@strong "strong emphasis")
    (@b "bold text")
    (@i "italic text")

## Code and Samples

    (@code "symbol-name")
    (@samp "sample text")
    (@var "variable")
    (@file "filename.lisp")
    (@command "ls -la")
    (@option "--verbose")

## Quotations and Examples

Use block commands for longer passages:

    (@quotation ()
      "This is a quoted passage.")
    (@example ()
      (@code "(defun hello ()")
      (@code "  (print \"Hello, World!\"))"))

# Cross References {#Cross-References}

## Within a Document

    (@xref "Node Name" "display text")
    (@ref "Node Name" "display text")
    (@anchor "anchor-name")

## External References

    (@url "https://example.com")
    (@uref "https://example.com" "Example Site")
    (@inforef "Node Name" "text" "manual-name")

# Lists and Tables {#Lists-and-Tables}

## Itemize Lists

    (@itemize ((@bullet))
      (@item "First item")
      (@item "Second item")
      (@item "Third item"))

## Enumerated Lists

    (@enumerate (1)
      (@item "Step one")
      (@item "Step two")
      (@item "Step three"))

## Tables

    (@table (@code)
      (@item "car")
      "Returns the first element of a list."
      (@itemx "cdr")
      "Returns the rest of a list.")

# Definition Commands {#Definition-Commands}

Texinfo provides specialized commands for documenting code:

## Variables

    (@defvar "*standard-input*")

## Functions

    (@deffn "Function" "format" "stream control-string &rest arguments")
    "Outputs formatted text to STREAM."

The library provides predefined definition commands:

-   `@defvar`, `@defopt` - Variable definitions

-   `@deftypevar` - Typed variable definitions

-   `@deffn`, `@deftypefn` - Function definitions

-   `@defmacro` - Macro definitions

-   `@defvr`, `@deftypevr` - Generic definitions

# Rendering Output {#Rendering-Output}

## String Output

Use `texinfo` to generate a string:

    (texinfo
      (@settitle "Document")
      (@chapter "Content"))

## File Output

Use `texinfo-to-file` to write directly to a file:

    (texinfo-to-file (#p"output.texi")
      (@settitle "My Document")
      (@chapter "Introduction"))
