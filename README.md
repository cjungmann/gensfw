# Project gensfw

This project is an excuse to practice BASH application programming using
[YAD](https://sourceforge.net/projects/yad-dialog/).

The other purpose for this project is to aid in the creation of
[Schema Framework](https://github.com/cjungmann/schemafw) scripts.

Other scripts available in the project are:
- [gensfw_session_procs](README_gensfw_session_procs.md) generates
  an SQL script implmenting several session procedures.
- [gensfw_srm_from_proc](README_gensfw_srm_from_proc.md) generates
  response modes based on the parameters of a stored procedure.
- [gensfw_srm_from_proc_result](README_gensfw_srm_from_proc_result.md)
  generates a response mode for the output of a stored procedure.
- [gensfw_srm](README_gensfw_srm.md) provides a means to edit an SRM
  file by use of rudimentary-XPATH-like syntax for selecting lines
  to add, remove, or change the value.
- [gensfw_proc_from_table](README_gensfw_proc_from_table.md) is a
  more easily batchable creator of stored procedures from table
  definitions.

## Unsuitablily of XSLT
I started with the idea that I would use XSLT stylesheets to build
dialogs and to interpret that saved file format.  I abandoned this
strategy early in the project for a few reasons:
- XSLT is not very adept at managing arrays.
- XSLT processing cannot handle non-typeable characters that I
  plan to use to save multi-dimensional arrays.
- The final problem that turned me off of XSLT: the XML output of
  MySQL does not include meta information.  The meta information
  must be acquired through a separate step and only in text format.
  Since I would have to parse the text anyway, it seemed logical
  to use this as an opportunity to develop a better mastery of
  BASH programming.

## Disclaimer

I have just started to work on this project.  This README is incomplete
and does not yet contain complete instructions nor even a complete
description.

The reason I am creating a repository for the project is because it
is now referenced by another project of mine,
[mysqlcb](https://github.com/cjungmann/libmysqlcb), which contains the
*xmlify* utility on which this *gensfw* project depends.

## Usage

**gensfw** is the new command name, and there are several options for
opening the program.

- `gensfw` alone will guide the user through selecting a database and
  table for processing.
- `gensfw CaseStudy` will begin running from the table selection
  dialog of database *CaseStudy*.
- `gensfw CaseStudy Person` will begin at the table processing dialog,
  using table *Person* from database *CaseStudy*.
- `gensfw CaseStudy_Person.gsf` will open a file that records the
  preferences in place when the file was created/updated.

## Requirements

This project uses several outside resources:
- The BASH shell
- MySQL Database Server
- [YAD](https://sourceforge.net/projects/yad-dialog/)
  - Install with your Linux distribution's version of `sudo apt-get install yad`
- [mysqlcb](https://github.com/cjungmann/libmysqlcb)
  - Download, configure, build, and install according to README instructions
  - This command/program runs a query and organizes the output before invoking
    a callback function that can use the query results.

Note that the Schema Framework is **not** necessary for this project.  It is
merely the intended consumer of the output of *gensfw*.

## YAD Yet-Another-Dialog

This utility is a capable tool for generating a graphical user interface
for a BASH program.  While it includes many more features than the project
from which is is derived (zenity), some interactions in *gensfw* are somewhat
awkward.  This is not a criticism of YAD, but only an attempt to temper
expectations of user-friendliness.

