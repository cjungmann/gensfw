# Supplemental Program *gensfw_srm_from_proc"

Creates a simplified response mode from the parameters of a stored procedure.
It is assumed that the procedure is for submitting a form of some sort since
a form is the only reason one would need a schema for the parameters of a named
procedure.

The program, given appropriate parameters, will generate two response modes,
the mode name to show the form, and second mode, with *_submit* appended to the
first mode name, that accepts the form mode's data.

Usage:

~~~sh
gensfw_srm_from_proc SFW_Simple App_Person_Add add
~~~

There are two required and one optional parameter to this program.

- **Database name** (required)
  Represented by the value *SFW_Simple* in the usage example above.  This
  is the database name in which the procedure will be found.

- **Procedure name** (required)
  Represented by the value *App_Person_Add* in the usage example above.
  This is the name of the procedure whose parameters will be used to generate
  a response mode with a simplified schema.

- **Mode name** (optional)
  Represented by the value *add* in the usage example above.  This is the
  mode name that will be used for the generated response mode.  If this
  parameter is omitted, the mode name will be *mode*.
