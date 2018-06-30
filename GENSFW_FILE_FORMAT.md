# GENSFW File Format

The **gsf** file saves developer preferences for a MySQL table for use
in generating different script files.

The **gensfw** file contents are text elements separated by different
non-typeable characters to break data into records, fields, and values.

The data is arranged as follows:

- **Record 0**
  - **Field 0**: Database Name
  - **Field 1**: Table Name
- **Record 1**: list of columns for the table in record 1 when the file
  was saved.
- **Record 2**: list, parallel to the column names, of default labels.
- **Record 3**: list, parallel to the column names, of linked session variables
- **Record 4**: Global SRM settings, array of values
  - First half of elements are the tags,
  - Second half of elements are values.
- **Record 5 to end**, each sub-record has:
  - **Field 0**: Interaction type name
  - **Field 1**: Include flag
  - **Field 2**: PageMode flag
  - **Field 3 to end**: YAD list interaction values, separated by the
    YAD separator (which is usually the same as the field separator).

The YAD list interaction values, field 2 of record 4

