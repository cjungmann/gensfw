<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" version="1.0" encoding="utf-8"/>

  <xsl:param name="dbase" />
  <xsl:param name="stem" />
  <xsl:param name="type" />
  <xsl:param name="includes" />
  <xsl:param name="session_compare_field" select="'id_account'" />
  <xsl:param name="select_confirm_field" />

  <xsl:param name="indent_code" select="'  '" />


  <xsl:variable name="nl"><xsl:text>&#xa;</xsl:text></xsl:variable>
  <xsl:variable name="apos"><xsl:text>&apos;</xsl:text></xsl:variable>
  <xsl:variable name="ispaces" select="'                                                          '" />

  <xsl:variable name="selecting_proc_type" select="$type='List' or $type='Read' or $type='Delete'" />
  <xsl:variable name="conf_field" select="//field[$selecting_proc_type][@name=$select_confirm_field]" />

  <!-- Templates to return conditions according to global values and parameters. -->
  <xsl:template name="selecting_proc_type">
    <xsl:choose>
      <xsl:when test="$type='List' or $type='Read' or $type='Delete'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="null_for_all">
    <xsl:choose>
      <xsl:when test="$type='List'">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Target-agnostic template that determines if a given field is in the includes list. -->
  <xsl:template match="field" mode="must_include">
    <xsl:param name="omit_key" />

    <xsl:variable name="pos" select="string-length($includes)-string-length(@name)" />
    <xsl:variable name="last" select="substring($includes,$pos)" />
    <xsl:choose>
      <xsl:when test="$omit_key and @primary_key">0</xsl:when>
      <xsl:when test="$includes=@name">1</xsl:when>
      <xsl:when test="starts-with($includes,concat(@name,'|'))">1</xsl:when>
      <xsl:when test="contains($includes,concat('|',@name,'|'))">1</xsl:when>
      <xsl:when test="$last=concat('|',@name)">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="drop_proc_stmt">
    <xsl:value-of select="concat('DROP PROCEDURE IF EXISTS ',$stem,$type,' $$',$nl)" />
  </xsl:template>

  <xsl:template name="create_proc_stmt">
    <xsl:value-of select="concat('CREATE PROCEDURE ',$stem,$type,'(')" />
  </xsl:template>

  <xsl:template name="create_if_row_count">
    <xsl:param name="indent" select="0" />
    <xsl:value-of select="concat($indent,'IF ROW_COUNT()&gt;0 THEN')" />
    <xsl:value-of select="concat($nl,$indent,$indent_code,'SET newid=LAST_INSERT_ID();')" />
    <xsl:value-of select="concat($nl,$indent,$indent_code,'CALL ',$stem,'List(newid);')" />
    <xsl:value-of select="concat($nl,$indent,'END IF;',$nl)" />
  </xsl:template>

  <xsl:template match="field" mode="get_datatype">
    <xsl:value-of select="@type" />
    <xsl:variable name="l3" select="substring(@type, (string-length(@type))-2)" />
    <xsl:choose>
      <xsl:when test="$l3='INT'">
        <xsl:if test="@unsigned"><xsl:text> UNSIGNED</xsl:text></xsl:if>
      </xsl:when>
      <xsl:when test="$l3='HAR' and @length">
        <xsl:value-of select="concat('(',@length,')')" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="field" mode="add_confirm_param">
    <xsl:value-of select="concat('conf_',@name,' ')" />
    <xsl:apply-templates select="." mode="get_datatype" />
  </xsl:template>

  <xsl:template match="field" mode="add_params">
    <xsl:param name="first" />
    <xsl:param name="indent" />
    <xsl:param name="omit_key" select="0" />

    <xsl:variable name="must_include">
      <xsl:apply-templates select="." mode="must_include">
        <xsl:with-param name="omit_key" select="$omit_key" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$must_include=1">
      <xsl:if test="not($first=1)"><xsl:value-of select="concat(',',$nl,$indent)" /></xsl:if>
      <xsl:value-of select="concat(@name,' ')" />
      <xsl:apply-templates select="." mode="get_datatype" />
    </xsl:if>

    <xsl:apply-templates select="following-sibling::field[1]" mode="add_params">
      <xsl:with-param name="first" select="($first)-($must_include)" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="omit_key" select="$omit_key" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="field" mode="add_fields">
    <xsl:param name="first" />
    <xsl:param name="indent" />
    <xsl:param name="omit_key" />
    <xsl:param name="prefix" />

    <xsl:variable name="must_include">
      <xsl:apply-templates select="." mode="must_include">
        <xsl:with-param name="omit_key" select="$omit_key" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$must_include=1">
      <xsl:if test="not($first=1)"><xsl:value-of select="concat(',',$nl,$indent)" /></xsl:if>
      <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
      <xsl:value-of select="@name" />
    </xsl:if>

    <xsl:apply-templates select="following-sibling::field[1]" mode="add_fields">
      <xsl:with-param name="first" select="($first)-($must_include)" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="omit_key" select="$omit_key" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="field" mode="add_sets">
    <xsl:param name="first" />
    <xsl:param name="indent" />
    <xsl:param name="omit_key" />
    <xsl:param name="prefix" />

    <xsl:variable name="must_include">
      <xsl:apply-templates select="." mode="must_include">
        <xsl:with-param name="omit_key" select="$omit_key" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$must_include=1">
      <xsl:if test="not($first=1)"><xsl:value-of select="concat(',',$nl,$indent)" /></xsl:if>
      <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
      <xsl:value-of select="concat(@name,'=',@name)" />
    </xsl:if>

    <xsl:apply-templates select="following-sibling::field[1]" mode="add_sets">
      <xsl:with-param name="first" select="($first)-($must_include)" />
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="omit_key" select="$omit_key" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Adds comma-separated field names with datatypes, for procedure parameters. -->
  <xsl:template match="schema" mode="add_params">
    <xsl:param name="indent" />
    <xsl:param name="first" select="1" />

    <xsl:if test="$conf_field">
      <xsl:apply-templates select="$conf_field" mode="add_confirm_param" />
    </xsl:if>

    <xsl:apply-templates select="field[1]" mode="add_params">
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="first" select="($first)-count($conf_field)" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Add comma-separated field names for SELECT, and INSERT commands. -->
  <xsl:template match="schema" mode="add_fields">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />
    <xsl:param name="first" select="1" />
    <xsl:param name="omit_key" select="0" />

    <xsl:apply-templates select="field[1]" mode="add_fields">
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="first" select="$first" />
      <xsl:with-param name="omit_key" select="$omit_key" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="schema" mode="add_sets">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />
    <xsl:param name="first" select="1" />

    <xsl:apply-templates select="field[1]" mode="add_sets">
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="omit_key" select="1" />
      <xsl:with-param name="first" select="$first" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Adds data source(s) (FROM tablename <prefix>) for a query. -->
  <xsl:template match="schema" mode="add_sources">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />

    <xsl:value-of select="concat($indent_code,'  FROM ')" />
    <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,' ')" /></xsl:if>
    <xsl:value-of select="concat(@name,$nl)" />
  </xsl:template>

  <!-- Adds conditions for the query.  Conditions will vary according to query type,
       and may include session confirmation and a confirming field.  The confirming
       field, if used, is an additional field that will be required in addition to
       the record ID to delete or something else. -->
  <xsl:template match="schema" mode="add_conditions">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />

    <xsl:variable name="pre">
      <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
    </xsl:variable>

    <xsl:variable name="null_for_all"><xsl:call-template name="null_for_all" /></xsl:variable>

    <xsl:variable name="idfield" select="field[@primary_key]/@name" />
    <xsl:variable name="where_str" select="concat($indent,' WHERE ')" />
    <xsl:variable name="windent" select="substring($ispaces,1,string-length($where_str))" />

    <xsl:value-of select="concat($indent_code,' WHERE ')" />
    <xsl:if test="$session_compare_field">
      <xsl:value-of select="concat($pre,$session_compare_field,'=@session_confirmed_account')" />
      <xsl:value-of select="concat($nl,$indent_code,'   AND (')" />
    </xsl:if>
    <xsl:if test="$null_for_all=1"><xsl:value-of select="concat($idfield,' IS NULL OR ')" /></xsl:if>
    <xsl:value-of select="concat($pre,$idfield,'=',$idfield)" />
    <xsl:if test="$session_compare_field"><xsl:text>)</xsl:text></xsl:if>
    <xsl:if test="$conf_field">
      <xsl:value-of
          select="concat($nl,$indent_code,'   AND conf_',$conf_field/@name,'=',$conf_field/@name)" />
    </xsl:if>

    <xsl:value-of select="concat(';',$nl)" />
  </xsl:template>

  <!-- Write Query for List Transaction -->
  <xsl:template match="schema" mode="writeqs_list">
    <xsl:variable name="prefix" select="'t'" />

    <xsl:variable name="cmd" select="concat($indent_code, 'SELECT ')" />
    <xsl:variable name="cmd_indent" select="substring($ispaces,1,string-length($cmd))" />

    <xsl:value-of select="$cmd" />

    <xsl:apply-templates select="." mode="add_fields">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:value-of select="$nl" />

    <xsl:apply-templates select="." mode="add_sources">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="add_conditions">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>
  </xsl:template>

  <!-- Write Query for Add Transaction -->
  <xsl:template match="schema" mode="writeqs_add">

    <xsl:variable name="cmd" select="concat($indent_code, 'INSERT INTO ',@name,' (')" />
    <xsl:variable name="cmd_len" select="string-length($cmd)" />
    <xsl:variable name="cmd_indent" select="substring($ispaces,1,$cmd_len)" />
    <xsl:variable name="values_indent" select="substring($ispaces,1,($cmd_len)-8)" />

    <xsl:value-of select="$cmd" />

    <xsl:apply-templates select="." mode="add_fields">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="omit_key" select="1" />
    </xsl:apply-templates>

    <xsl:if test="$session_compare_field">
      <xsl:value-of select="concat(',',$nl,$cmd_indent,$session_compare_field)" />
    </xsl:if>

    <xsl:value-of select="concat(')',$nl,$values_indent,'VALUES (')" />

    <xsl:apply-templates select="." mode="add_fields">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="omit_key" select="1" />
    </xsl:apply-templates>

    <xsl:if test="$session_compare_field">
      <xsl:value-of select="concat(',',$nl,$cmd_indent,'@session_confirmed_account')" />
    </xsl:if>

    <xsl:text>)</xsl:text>

    <xsl:if test="$session_compare_field">
      <xsl:value-of
          select="concat($nl,$values_indent,' WHERE @session_confirmed_account IS NOT NULL')" />
    </xsl:if>

    <xsl:value-of select="concat(';',$nl,$nl)" />

    <xsl:call-template name="create_if_row_count">
      <xsl:with-param name="indent" select="$indent_code" />
    </xsl:call-template>
  </xsl:template>

  <!-- Write Query for Read Transaction -->
  <xsl:template match="schema" mode="writeqs_read">
    <xsl:variable name="prefix" select="'t'" />

    <xsl:variable name="cmd" select="concat($indent_code, 'SELECT ')" />
    <xsl:variable name="cmd_indent" select="substring($ispaces,1,string-length($cmd))" />

    <xsl:value-of select="$cmd" />

    <xsl:apply-templates select="." mode="add_fields">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:value-of select="$nl" />

    <xsl:apply-templates select="." mode="add_sources">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="add_conditions">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Write Query for Update Transaction -->
  <xsl:template match="schema" mode="writeqs_update">
    <xsl:variable name="prefix" select="'t'" />

    <xsl:variable name="pre">
      <xsl:if test="$prefix"><xsl:value-of select="concat(' ',$prefix)" /></xsl:if>
    </xsl:variable>

    <xsl:variable name="cmd" select="concat($indent_code,'UPDATE ',@name,$pre,$nl)" />
    <xsl:variable name="cmd_set" select="concat($indent_code,'   SET ')" />
    <xsl:variable name="cmd_len" select="string-length($cmd_set)" />
    <xsl:variable name="cmd_indent" select="substring($ispaces,1,$cmd_len)" />
    <xsl:variable name="values_indent" select="substring($ispaces,1,($cmd_len)-8)" />

    <xsl:value-of select="concat($cmd,$cmd_set)" />

    <xsl:apply-templates select="." mode="add_sets">
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="indent" select="$cmd_indent" />
    </xsl:apply-templates>

    <xsl:value-of select="$nl" />

    <xsl:apply-templates select="." mode="add_conditions">
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="indent" select="$cmd_indent" />
    </xsl:apply-templates>
    
  </xsl:template>
  
  <!-- Write Query for Delete Transaction -->
  <xsl:template match="schema" mode="writeqs_delete">
    <xsl:variable name="prefix" select="'t'" />

    <xsl:variable name="from">
      <xsl:choose>
        <xsl:when test="$prefix">
          <xsl:value-of select="concat($prefix,' USING ',@name,' AS ',$prefix)" />
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="@name" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="cmd" select="concat($indent_code, 'DELETE ')" />
    <xsl:variable name="cmd_from" select="concat($nl,$indent_code, '  FROM ',$from,$nl)" />
    <xsl:variable name="cmd_indent" select="substring($ispaces,1,string-length($cmd))" />

    <xsl:value-of select="concat($cmd,$cmd_from)" />

    <xsl:apply-templates select="." mode="add_conditions">
      <xsl:with-param name="indent" select="$cmd_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="schema" mode="write_queries">
    <xsl:choose>
      <xsl:when test="$type='List'">
        <xsl:apply-templates select="." mode="writeqs_list" />
      </xsl:when>
      <xsl:when test="$type='Add'">
        <xsl:apply-templates select="." mode="writeqs_add" />
      </xsl:when>
      <xsl:when test="$type='Read'">
        <xsl:apply-templates select="." mode="writeqs_read" />
      </xsl:when>
      <xsl:when test="$type='Update'">
        <xsl:apply-templates select="." mode="writeqs_update" />
      </xsl:when>
      <xsl:when test="$type='Delete'">
        <xsl:apply-templates select="." mode="writeqs_delete" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  

  <xsl:template match="schema">
    <xsl:value-of select="concat('DELIMITER $$',$nl,$nl)" />

    <xsl:apply-templates select="." mode="make_proc" />

    <xsl:value-of select="concat('DELIMITER ;',$nl)" />
  </xsl:template>


  <xsl:template match="schema" mode="make_proc">

    <xsl:call-template name="drop_proc_stmt" />
    <xsl:variable name="create_proc_str"><xsl:call-template name="create_proc_stmt" /></xsl:variable>

    <xsl:value-of select="$create_proc_str" />
    <xsl:apply-templates select="." mode="add_params">
      <xsl:with-param name="indent" select="substring($ispaces,1,string-length($create_proc_str))" />
    </xsl:apply-templates>

    <xsl:value-of select="concat(')',$nl,'BEGIN',$nl)" />
    <xsl:apply-templates select="." mode="write_queries" />
    <xsl:value-of select="concat('END $$',$nl,$nl)" />
    
    
  </xsl:template>




</xsl:stylesheet>
