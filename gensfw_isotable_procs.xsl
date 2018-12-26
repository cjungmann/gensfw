<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="utf-8"/>

  <xsl:param name="prefix">App_PersonType1_</xsl:param>
  <xsl:param name="delimiter" select="'$$'" />
  <xsl:param name="table_name" select="'TEMP_TABLE'" />

  <xsl:variable name="nl" select="'&#10;'" />
  <xsl:variable name="apos">'</xsl:variable>

  <xsl:variable name="rows" select="/resultset/row" />

  <xsl:variable name="minors">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="majors">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <xsl:variable name="tname_template">TEMP_LINES_TABLE</xsl:variable>

  <xsl:template match="/">

    <xsl:text>DELIMITER </xsl:text>
    <xsl:value-of select="concat($delimiter,$nl)" />

    <xsl:apply-templates select="resultset" mode="make_create_table_proc">
      <xsl:with-param name="fields" select="$rows" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:apply-templates select="resultset" mode="make_parse_rows_proc">
      <xsl:with-param name="fields" select="$rows" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:value-of select="concat($nl,'DELIMITER ;',$nl)" />
  </xsl:template>

  <!-- Returns maximum value of list of space-separated integers. -->
  <xsl:template name="get_max_value">
    <xsl:param name="list" />
    <xsl:param name="max" select="0" />

    <xsl:variable name="after" select="substring-after($list,' ')" />

    <xsl:variable name="cur">
      <xsl:choose>
        <xsl:when test="$after">
          <xsl:value-of select="substring-before($list,' ')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$list" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="new_max">
      <xsl:choose>
        <xsl:when test="($cur) &gt; ($max)">
          <xsl:value-of select="$cur" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$max" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$after">
        <xsl:call-template name="get_max_value">
          <xsl:with-param name="list" select="$after" />
          <xsl:with-param name="max" select="$new_max" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$new_max" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Make list of lengths of row names from which to extract the max. -->
  <xsl:template match="row" mode="name_len_list">
    <xsl:variable name="name" select="field[@name='COLUMN_NAME']" />

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="' '" />
    </xsl:if>
    <xsl:value-of select="string-length($name)" />
  </xsl:template>

  <!-- Make string of spaces from number of spaces needed. -->
  <xsl:template name="pad">
    <xsl:param name="spaces" select="0" />
    <xsl:if test="$spaces &gt; 0">
      <xsl:value-of select="' '" />
      <xsl:call-template name="pad">
        <xsl:with-param name="spaces" select="($spaces)-1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Make string of spaces the same length as a string parameter. -->
  <xsl:template name="spacify">
    <xsl:param name="str" />
    <xsl:text> </xsl:text>
    <xsl:if test="string-length($str) &gt; 1">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="substring($str,2)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Set $dedent_first parameter if the first field should be output
       without a preceding newline, ie as procedure parameters). -->
  <xsl:template match="row" mode="table_def_field">
    <xsl:param name="indent" />
    <xsl:param name="name_max_len" select="0" />
    <xsl:param name="dedent_first" />

    <xsl:variable name="name" select="field[@name='COLUMN_NAME']" />
    <xsl:variable name="type" select="field[@name='COLUMN_TYPE']" />

    <xsl:variable name="extra">
      <xsl:if test="$name_max_len &gt; 0">
        <xsl:call-template name="pad">
          <xsl:with-param
              name="spaces"
              select="($name_max_len)-string-length($name)" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="concat(',',$nl)" />
    </xsl:if>

    <xsl:if test="not(position()=1) or not($dedent_first)">
      <xsl:value-of select="$indent" />
    </xsl:if>

    <xsl:value-of
        select="concat($name,$extra,' ',translate($type,$minors,$majors))" />
    
  </xsl:template>

  <!-- Create a temporary table from the fields list. -->
  <xsl:template match="resultset" mode="temp_table_def">
    <xsl:param name="table_name" />
    <xsl:param name="fields" select="/.." />
    <xsl:param name="indent" select="''" />

    <xsl:variable name="row_len_list">
      <xsl:apply-templates select="$fields" mode="name_len_list" />
    </xsl:variable>

    <xsl:variable name="name_max_len">
      <xsl:call-template name="get_max_value">
        <xsl:with-param name="list" select="$row_len_list" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$indent" />
    <xsl:text>DROP TABLE IF EXISTS </xsl:text>
    <xsl:value-of select="concat($table_name,';',$nl)" />
    <xsl:value-of select="$indent" />
    <xsl:text>CREATE TEMPORARY TABLE IF NOT EXISTS </xsl:text>
    <xsl:value-of select="concat($table_name,$nl,$indent,'(',$nl)" />

    <xsl:apply-templates select="$fields" mode="table_def_field">
      <xsl:with-param name="indent" select="concat($indent,'   ')" />
      <xsl:with-param name="name_max_len" select="$name_max_len" />
    </xsl:apply-templates>

    <xsl:value-of select="concat($nl,$indent,');',$nl)" />

  </xsl:template>


  <!-- DECLAREs for temporary variables that hold each value before INSERT. -->
  <xsl:template match="row" mode="declare_field_buffer">
    <xsl:param name="indent" select="''" />
    <xsl:param name="name_max_len" select="0" />

    <xsl:variable name="name"
                  select="field[@name='COLUMN_NAME']" />
    <xsl:variable
        name="type"
        select="translate(field[@name='COLUMN_TYPE'],$minors,$majors)" />

    <xsl:variable name="extra">
      <xsl:if test="$name_max_len &gt; 0">
        <xsl:call-template name="pad">
          <xsl:with-param
              name="spaces"
              select="($name_max_len)-string-length($name)" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:value-of
        select="concat($indent,'DECLARE ',$name,$extra,' ',$type,';',$nl)" />
  </xsl:template>

  <!-- Generate statements that NULL field buffer variables for each iteration. -->
  <xsl:template match="row" mode="null_field_buffer">
    <xsl:param name="indent" select="''" />
    <xsl:param name="name_max_len" select="0" />

    <xsl:variable name="name"
                  select="field[@name='COLUMN_NAME']" />

    <xsl:variable name="extra">
      <xsl:if test="$name_max_len &gt; 0">
        <xsl:call-template name="pad">
          <xsl:with-param
              name="spaces"
              select="($name_max_len)-string-length($name)" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:value-of
        select="concat($indent,'SET ',$name,$extra,' = NULL;',$nl)" />
  </xsl:template>

  <!-- Generate WHEN lines for CASE NDX_INDEX -->
  <xsl:template match="row" mode="set_by_index">
    <xsl:param name="indent" select="''" />

    <xsl:variable name="ndx" select="position() - 1" />
    <xsl:variable name="name"
                  select="field[@name='COLUMN_NAME']" />

    <xsl:value-of
        select="concat($indent,'WHEN ',$ndx,' THEN SET ',$name,' = CUR_FIELD;',$nl)" />
  </xsl:template>

  <!-- Generate IF statement that confirms no field is NULL -->
  <xsl:template match="row" mode="confirm_not_null">
    <xsl:variable name="name"
                  select="field[@name='COLUMN_NAME']" />

    <xsl:if test="position() &gt; 1">
      <xsl:text> AND </xsl:text>
    </xsl:if>

    <xsl:value-of select="concat($name,' IS NOT NULL')" />
  </xsl:template>

  <xsl:template match="row" mode="field_list">
    <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:value-of select="field[@name='COLUMN_NAME']" />
  </xsl:template>

  <xsl:template match="row" mode="field_list">
    <xsl:param name="enclose" />
    <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:if test="$enclose"><xsl:text>[</xsl:text></xsl:if>
    <xsl:value-of select="field[@name='COLUMN_NAME']" />
    <xsl:if test="$enclose"><xsl:text>]</xsl:text></xsl:if>
  </xsl:template>

  <xsl:template match="resultset" mode="make_create_table_proc">
    <xsl:param name="fields" select="/.." />
    <xsl:param name="prefix" select="''" />

    <xsl:variable name="proc_name" select="concat($prefix,'Create_Temp_Table')" />

    <xsl:text>DROP PROCEDURE IF EXISTS </xsl:text>
    <xsl:value-of select="concat($proc_name,' ',$delimiter,$nl)" />
    <xsl:text>CREATE PROCEDURE </xsl:text>
    <xsl:value-of select="concat($proc_name,'()')" />
    <xsl:value-of select="concat($nl,'BEGIN',$nl)" />

    <xsl:apply-templates select="." mode="temp_table_def">
      <xsl:with-param name="table_name" select="$table_name" />
      <xsl:with-param name="fields" select="$fields" />
      <xsl:with-param name="indent" select="'   '" />
    </xsl:apply-templates>
    <xsl:value-of select="concat('END',' ',$delimiter,$nl,$nl)" />
  </xsl:template>

  <xsl:template match="resultset" mode="make_parse_rows_proc">
    <xsl:param name="fields" select="/.." />
    <xsl:param name="prefix" select="''" />

    <xsl:variable name="proc_name" select="concat($prefix,'Fill_Temp_Table')" />

    <xsl:variable name="indent" select="'   '" />

    <xsl:variable name="row_len_list">
      <xsl:apply-templates select="$fields" mode="name_len_list" />
    </xsl:variable>

    <xsl:variable name="name_max_len">
      <xsl:call-template name="get_max_value">
        <xsl:with-param name="list" select="$row_len_list" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:text>DROP PROCEDURE IF EXISTS </xsl:text>
    <xsl:value-of select="concat($proc_name,' ',$delimiter,$nl)" />
    <xsl:text>CREATE PROCEDURE </xsl:text>
    <xsl:value-of select="concat($proc_name,'(lines TEXT)')" />

    <xsl:value-of select="concat($nl,'BEGIN',$nl)" />

    <xsl:value-of select="concat($indent,'DECLARE TOK_LINE   CHAR(1);',$nl)" />
    <xsl:value-of select="concat($indent,'DECLARE TOK_FIELD  CHAR(1);',$nl)" />

    <xsl:value-of select="concat($indent,'DECLARE REM_LINES  TEXT;',$nl)" />
    <xsl:value-of select="concat($indent,'DECLARE REM_FIELDS TEXT;',$nl)" />
    <xsl:value-of select="concat($indent,'DECLARE CUR_FIELD  TEXT;',$nl)" />
    <xsl:value-of select="concat($indent,'DECLARE NDX_FIELD  INT UNSIGNED;',$nl)" />

    <xsl:value-of select="$nl" />
    <xsl:apply-templates select="$fields" mode="declare_field_buffer">
      <xsl:with-param name="fields" select="$fields" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="name_max_len" select="$name_max_len" />
    </xsl:apply-templates>

    <xsl:value-of select="concat($nl,$indent)" />
    <xsl:text>SELECT ';', '|' INTO TOK_LINE, TOK_FIELD;</xsl:text>
    <xsl:value-of select="concat($nl,$indent)" />
    <xsl:text>SET REM_LINES = lines;</xsl:text>

    <xsl:value-of select="concat($nl,$indent)" />
    <xsl:text>WHILE LENGTH(REM_LINES) &gt; 0 DO</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent)" />
    <xsl:text>SET REM_FIELDS = SUBSTRING_INDEX(REM_LINES, TOK_LINE, 1);</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent)" />
    <xsl:text>SET REM_LINES = SUBSTRING(REM_LINES, LENGTH(REM_FIELDS)+2);</xsl:text>
    <xsl:value-of select="concat($nl,$nl)" />

    <xsl:apply-templates select="$fields" mode="null_field_buffer">
      <xsl:with-param name="fields" select="$fields" />
      <xsl:with-param name="indent" select="concat($indent,$indent)" />
      <xsl:with-param name="name_max_len" select="$name_max_len" />
    </xsl:apply-templates>

    <xsl:value-of select="concat($nl,$indent,$indent)" />
    <xsl:text>WHILE LENGTH(REM_FIELDS) &gt; 0 DO</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent,$indent)" />
    <xsl:text>SET CUR_FIELD = SUBSTRING_INDEX(REM_FIELDS, TOK_FIELD, 1);</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent,$indent)" />
    <xsl:text>SET REM_FIELDS = SUBSTRING(REM_FIELDS, LENGTH(CUR_FIELD)+2);</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent,$indent)" />

    <xsl:text>CASE NDX_FIELD</xsl:text>
    <xsl:value-of select="$nl" />
    <xsl:apply-templates select="$fields" mode="set_by_index">
      <xsl:with-param name="fields" select="$fields" />
      <xsl:with-param name="indent" select="concat($indent,$indent,$indent,$indent)" />
    </xsl:apply-templates>
    <xsl:value-of select="concat($indent,$indent,$indent)" />
    <xsl:text>END CASE;</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent,$indent)" />
    <xsl:text>SET NDX_FIELD = NDX_FIELD + 1;</xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent)" />
    <xsl:text>END WHILE;</xsl:text>

    <xsl:value-of select="concat($nl,$nl,$indent,$indent)" />
    <xsl:text>IF </xsl:text>
    <xsl:apply-templates select="$fields" mode="confirm_not_null" />
    <xsl:text> THEN </xsl:text>
    <xsl:value-of select="concat($nl,$indent,$indent,$indent)" />
    <xsl:text>INSERT INTO </xsl:text>
    <xsl:value-of select="$table_name" />
    <xsl:value-of select="concat($nl,$indent,$indent,$indent,$indent,'(')" />
    <xsl:apply-templates select="$fields" mode="field_list">
      <xsl:with-param name="enclose" select="1" />
    </xsl:apply-templates>
    <xsl:value-of select="concat(')',$nl,$indent,$indent,$indent,'VALUES')" />
    <xsl:value-of select="concat($nl,$indent,$indent,$indent,$indent)" />
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="$fields" mode="field_list" />
    <xsl:text>);</xsl:text>

    <xsl:value-of select="concat($nl,$indent,$indent)" />
    <xsl:text>END IF;</xsl:text>
    <xsl:value-of select="concat($nl,$indent)" />
    <xsl:text>END WHILE;</xsl:text>

    <xsl:value-of select="concat($nl,'END ', $delimiter, $nl)" />
    

  </xsl:template>

</xsl:stylesheet>
