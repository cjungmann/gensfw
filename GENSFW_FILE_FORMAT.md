# GENSFW File Format

The **gsf** file saves developer preferences for a MySQL table for use
in generating different script files.

The **gensfw** file contents are text elements separated by different
non-typeable characters to break data into records, fields, and values.

The data is arranged as follows:

- **Record 1**
  - **Field 1**: Database Name
  - **Field 2**: Table Name
- **Record 2**: list of columns for the table in record 1 when the file
  was saved.
- **Record 3**: list, parallel to the column names, of default labels.
- **Record 4 to end**:
  - **Field 1**: Interaction type name
  - **Field 2 to end**: YAD list interaction values, separated by the
    YAD separator (which is usually the same as the field separator).



