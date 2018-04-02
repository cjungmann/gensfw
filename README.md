# Project gensfw

This project is an excuse to practice BASH application programming using
[YAD](https://sourceforge.net/projects/yad-dialog/).

The other purpose for this project is to aid in the creation of
[Schema Framework](https://github.com/cjungmann/schemafw) scripts.  I am
also experimenting with the practicality of using XSLT processing along
with the BASH commands.

## Disclaimer

I have just started to work on this project.  This README is incomplete
and does not yet contain complete instructions nor even a complete
description.

The reason I am creating a repository for the project is because it
is now referenced by another project of mine,
[mysqlcb](https://github.com/cjungmann/libmysqlcb), which contains the
*xmlify* utility on which this *gensfw* project depends.

## Usage

`gensfw DatabaseName TableName`
for example:
~~~sh
 $ ./gensfw TestGenSFW Person
~~~

## Requirements

This project uses several outside resources:
- The BASH shell
- MySQL Database Server
- [YAD](https://sourceforge.net/projects/yad-dialog/)
  - Install with your Linux distribution's version of `sudo apt-get install yad`
- [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html)
  - Install with `sudo apt-get install xsltproc`
- [mysqlcb](https://github.com/cjungmann/libmysqlcb)
  - Download, configure, build, and install according to README instructions

Note that the Schema Framework is **not** necessary for this project.  It is
merely the intended consumer of the output of *gensfw*.


## XSLT Processing

A large part of the project is using XSLT to generate the scripts from
the XML schemas.  Additionally, the single (for now) XSLT script also
generates BASH commands for creating BASH variables for tracking values
from one instantiation of *yad* to the next.

The project requires that [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html)
is installed on your computer.  

Since this project is still in development, I'm adding instructions
for continuing development, including the creation of test files and
the direct use of the XSLT stylesheets.  This shouldn't be necessary for
an end-user, who should just use *gensfw* as found, but might be useful
for others who might want to extend it or to just consider these
strategies for other projects.

### XSLT Files

The obvious file, [main.xsl](blob/master/main.xsl) is part of the
repository.  The XML file that *gensfw* uses is never written to disk,
but can be generated for testing.  For example, the default parameters
(i.e. the values used when no parameters are passed to the command)
of *gensfw* use table *Person* from database *TestGenSFW*.  This XML
document can be created for testing with the following command:

~~~sh
$ xmlify -t Person TestGenSFW > person.xml
~~~

### XSLT Development

At this writing, the XSLT stylesheet contains four parameters that are
to be filled in by *gensfw*.  These parameters, **dbase**, **mode**, **stem**,
and **includes** have default values for testing with the *xsltproc*
command.

To use the default parameters with the test XML document we create above,
simply invoke *xsltproc* like this:

~~~sh
$ xsltproc main.xsl person.xml
~~~

Different parameters can be used by either editing *main.xsl* or by
explicitely including parameters in the command line.  Consider the following
example that requests an *srm* output in place of the default *sql* output:

~~~sh
$ xsltproc --stringparam mode srm main.xsl person.xml
~~~

