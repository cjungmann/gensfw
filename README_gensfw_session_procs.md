# SCRIPT gensfw_session_procs

This moderately simple script uses a MySQL table description
for session information to build a set of procedures to
satisfy the built-in session handling procedures for the
SchemaServer object **schema.fcgi**.

The *gensfw_session_procs** script is installed along with
[gensfw](README.md)

## Invoking The Script

~~~sh
$ gensfw_session_procs [database name] [session info table name]
~~~

There are two possible ways to use this, either to write the
output from *stdout* to a file, or pipe it directly into
MySQL.  The following examples are creating session procedures
for database **Phonebook**, which has the session information
in table **Session_Info**.

### Write Script to File

~~~sh
$ gensfw_session_procs Phonebook Session_Info > session_procs.sql
~~~

### Write Script Directly to MySQL

~~~sh
$ gensfw_session_procs Phonebook Session_Info | mysql
~~~

## Overriding Required Session Procedures

The following procedures, for which the setup provides empty
procedures, are required by the framework.  These procedures
are replaced by the *gensfw_session_procs*:
- App_Session_Start
- App_Session_Restore
- App_Session_Abandon
- App_Session_Cleanup

## Session Value-Setting Helper Functions

In addition to the required session procedures, the script
will write a helper procedure for each field in the session
information table.  The helper procedure will set both the
current session value *and* the synonymously-named table
field in the session information table, making the value
persistent.

The helper function will be in the form **App_Session_Set_<field_name>**.
For example, for a field name **user_name**, the helper function
will be called **App_Session_Set_user_name**.

## Using XSL For This Script

The parsing requirements for this script are much simpler than
[gensfw](README.md) because there are no options offered.  The
full set of procedures are created based on the table identified
as the session information table.  Because of this, I am using
XSLT to generate the script file.