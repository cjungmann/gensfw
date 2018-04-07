<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" version="1.0" encoding="utf-8"/>

  <xsl:param name="dbase" select="'TestGenSFW'" />
  <xsl:param name="mode" select="'sql'" />
  <xsl:param name="stem" select="'App_Person_'" />
  <xsl:param name="includes" select="'id|fname|dob'" />
  <xsl:param name="session_compare_field" select="'id_account'" />

  <xsl:param name="indent_code" select="'  '" />

  <xsl:variable name="apos"><xsl:text>&apos;</xsl:text></xsl:variable>
  <xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>

   <xsl:template name="padstr">
     <xsl:param name="len" />
     <xsl:if test="$len &gt; 0">
       <xsl:text> </xsl:text>
       <xsl:call-template name="padstr">
         <xsl:with-param name="len" select="($len)-1" />
       </xsl:call-template>
     </xsl:if>
   </xsl:template>

  <xsl:template match="/">
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="resultset">
    <xsl:choose>
      <xsl:when test="$mode='vars'">
        <xsl:apply-templates select="*" mode="show_vars" />
      </xsl:when>
      <xsl:when test="$mode='srm'">
        <xsl:apply-templates select="*" mode="srm" />
      </xsl:when>
      <xsl:when test="$mode='sql'">
        <xsl:apply-templates select="*" mode="sql" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Missing mode parameter</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="field" mode="as_value">
    <xsl:if test="position() &gt; 1"><xsl:text>|</xsl:text></xsl:if>
    <xsl:value-of select="@name" />
  </xsl:template>

  <xsl:template match="schema" mode="show_vars">
    <xsl:apply-templates select="*" mode="show_vars" />
  </xsl:template>

  <xsl:template match="field" mode="show_vars">
    <xsl:value-of select="concat(@name,$nl)" />
  </xsl:template>

  <xsl:template match="schema" mode="srm">
    <xsl:value-of select="concat('$database       : ',$dbase,$nl)" />
    <xsl:value-of select="concat('$xml-stylesheet : default.xsl',$nl)" />
    <xsl:value-of select="concat($nl,$nl)" />

  </xsl:template>


  <xsl:template match="field" mode="sql_write_dtype">
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

  <xsl:template match="field" mode="sql_write_param">
    <xsl:value-of select="concat(@name,' ')" />
    <xsl:apply-templates select="." mode="sql_write_dtype" />
  </xsl:template>

  <xsl:template match="field" mode="sql_write_index_param">
    <xsl:text>id </xsl:text>
    <xsl:apply-templates select="." mode="sql_write_dtype" />
  </xsl:template>

  <xsl:template match="schema" mode="sql_add_params">
    <xsl:param name="str" />
    <xsl:param name="indent" />
    <xsl:param name="skip_id" />

    <xsl:variable name="before" select="substring-before($str,'|')" />
    <xsl:variable name="blen" select="string-length($before)" />
    <xsl:variable name="after" select="substring($str,1 div boolean($blen=0))" />
    <xsl:variable name="name" select="concat($before,$after)" />

    <xsl:variable name="field" select="field[@name=$name][not(@primary_key and $skip_id)]" />

    <xsl:apply-templates select="$field" mode="sql_write_param" />

    <xsl:if test="$blen">
      <xsl:if test="count($field)">
        <xsl:value-of select="concat(',',$nl,$indent)" />
      </xsl:if>

      <xsl:apply-templates select="." mode="sql_add_params">
        <xsl:with-param name="str" select="substring-after($str,'|')" />
        <xsl:with-param name="indent" select="$indent" />
        <xsl:with-param name="skip_id" select="$skip_id" />
      </xsl:apply-templates>
    </xsl:if>

  </xsl:template>

  <xsl:template name="sql_drop_proc">
    <xsl:param name="type" />
    <xsl:value-of select="concat('DROP PROCEDURE IF EXISTS ',$stem,$type,' $$',$nl)" />
  </xsl:template>

  <xsl:template name="sql_create_proc_to_open_paren">
    <xsl:param name="type" />
    <xsl:value-of select="concat('CREATE PROCEDURE ',$stem,$type,'(')" />
  </xsl:template>

  <xsl:template match="schema" mode="sql_start_proc_with_id">
    <xsl:param name="type" />

    <xsl:variable name="create_proc_stem">
      <xsl:call-template name="sql_create_proc_to_open_paren">
        <xsl:with-param name="type" select="$type" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="id_field" select="field[@primary_key]" />

    <!-- Start writing procedure: -->
    <xsl:call-template name="sql_drop_proc">
      <xsl:with-param name="type" select="$type" />
    </xsl:call-template>

    <xsl:value-of select="$create_proc_stem" />
    <xsl:apply-templates select="$id_field" mode="sql_write_index_param" />
    <xsl:value-of select="concat(')',$nl,'BEGIN',$nl)" />

  </xsl:template>

  <xsl:template match="schema" mode="sql_start_proc_with_params">
    <xsl:param name="type" />
    <xsl:param name="skip_id" />

    <xsl:variable name="create_proc_stem">
      <xsl:call-template name="sql_create_proc_to_open_paren">
        <xsl:with-param name="type" select="$type" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="sql_drop_proc">
      <xsl:with-param name="type" select="$type" />
    </xsl:call-template>

    <xsl:value-of select="$create_proc_stem" />

    <xsl:variable name="spaces_to_paren">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="string-length($create_proc_stem)" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:apply-templates select="." mode="sql_add_params">
      <xsl:with-param name="str" select="$includes" />
      <xsl:with-param name="indent" select="$spaces_to_paren" />
      <xsl:with-param name="skip_id" select="$skip_id" />
    </xsl:apply-templates>

    <xsl:value-of select="concat(')',$nl)" />
  </xsl:template>

  <!-- Target-agnostic template that determines if a given field is in the includes list. -->
  <xsl:template match="field" mode="must_include">
    <xsl:param name="skip_id" />

    <xsl:variable name="pos" select="string-length($includes)-string-length(@name)" />
    <xsl:variable name="last" select="substring($includes,$pos)" />
    <xsl:choose>
      <xsl:when test="$skip_id and @primary_key">0</xsl:when>
      <xsl:when test="$includes=@name">1</xsl:when>
      <xsl:when test="starts-with($includes,concat(@name,'|'))">1</xsl:when>
      <xsl:when test="contains($includes,concat('|',@name,'|'))">1</xsl:when>
      <xsl:when test="$last=concat('|',@name)">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="field" mode="sql_write_selects">
    <xsl:param name="prefix" />
    <xsl:param name="indent" select="''" />

    <xsl:variable name="include">
      <xsl:apply-templates select="." mode="must_include" />
    </xsl:variable>

    <xsl:if test="$include=1">
      <xsl:value-of select="concat(',',$nl,$indent)" />
      <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
      <xsl:value-of select="@name" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="field" mode="sql_add_proc_field">
    <xsl:param name="indent" />
    <xsl:param name="first" select="1" />

    <xsl:variable name="include">
      <xsl:apply-templates select="." mode="must_include">
        <xsl:with-param name="skip_id" select="1" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$include=1">
        <xsl:if test="not($first=1)"><xsl:value-of select="concat(',',$nl,$indent)" /></xsl:if>
        <xsl:value-of select="@name" />
    </xsl:if>

    <xsl:apply-templates select="following-sibling::field[1]" mode="sql_add_proc_field">
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="first" select="($first) - ($include)" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="field" mode="sql_update_set_field">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />
    <xsl:param name="first" select="1" />

    <xsl:variable name="include">
      <xsl:apply-templates select="." mode="must_include">
        <xsl:with-param name="skip_id" select="1" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$include=1">
      <xsl:if test="not($first=1)">,</xsl:if>
      <xsl:value-of select="concat($nl,$indent_code)" />

      <xsl:choose>
        <xsl:when test="$first=1"><xsl:text>   SET </xsl:text></xsl:when>
        <xsl:otherwise><xsl:text>       </xsl:text></xsl:otherwise>
      </xsl:choose>

      <xsl:value-of select="concat($prefix,'.',@name,'=',@name)" />

    </xsl:if>

    <xsl:apply-templates select="following-sibling::field[1]" mode="sql_update_set_field">
      <xsl:with-param name="indent" select="$indent" />
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="first" select="($first) - ($include)" />
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="schema" mode="sql_write_conditions">
    <xsl:param name="indent" />
    <xsl:param name="prefix" />
    <xsl:param name="null_override" />

    <xsl:variable name="pre"
                  select="concat($prefix,substring('.',1 div boolean(string-length($prefix)!=0)))" />
    <xsl:variable name="id_field" select="field[@primary_key]" />
    <xsl:variable name="session_field" select="field[@name=$session_compare_field]" />
    <xsl:variable name="and_indent" select="concat($indent,'   AND ')" />
    <xsl:variable name="or_indent"  select="concat($indent,'    OR ')" />

    <xsl:value-of select="concat($indent,' WHERE ')" />
    <xsl:if test="$session_field">
      <xsl:value-of
          select="concat($pre,$session_field/@name,'=@session_confirmed_id',$nl,$and_indent)" />
    </xsl:if>

    <xsl:if test="$null_override">
      <xsl:value-of select="concat('(',$pre,$id_field/@name,' IS NULL OR ')" />
    </xsl:if>
    <xsl:value-of select="concat($pre,$id_field/@name,'=id')" />
    <xsl:if test="$null_override">)</xsl:if>

    <xsl:value-of select="concat(';',$nl)" />
  </xsl:template>

  <xsl:template name="sql_if_row_count">
    <xsl:value-of select="concat($nl,$indent_code,'IF ROW_COUNT()&gt;0 THEN')" />
    <xsl:value-of select="concat($nl,$indent_code,$indent_code,'SET newid = LAST_INSERT_ID();')" />
    <xsl:value-of select="concat($nl,$indent_code,$indent_code,'CALL ',$stem,'List(newid);')" />
    <xsl:value-of select="concat($nl,$indent_code,'END IF;',$nl)" />
  </xsl:template>


  <xsl:template match="schema" mode="sql_write_proc_list">
    <xsl:variable name="prefix" select="'t'" />
    <xsl:variable name="type" select="'List'" />

    <xsl:variable name="selline" select="concat($indent_code,'SELECT ')" />
    <xsl:variable name="indent_field">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="string-length($selline)" />
      </xsl:call-template>
    </xsl:variable>

    <!-- DROP and CREATE PROC -->
    <xsl:apply-templates select="." mode="sql_start_proc_with_id">
      <xsl:with-param name="type" select="$type" />
      <xsl:with-param name="indent" select="$indent_field" />
    </xsl:apply-templates>

    <!-- Procedure declaration -->
    <!-- SELECT fields -->
    <xsl:value-of select="$selline" />
    <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
    <xsl:value-of select="field[@primary_key]/@name" />
    <xsl:apply-templates select="field[not(@primary_key)]" mode="sql_write_selects">
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="indent" select="$indent_field" />
    </xsl:apply-templates>
    <!-- FROM -->
    <xsl:value-of select="concat($nl,$indent_code,'  FROM ', $dbase,' ',$prefix,$nl)" />
    <!-- Condition -->
    <xsl:apply-templates select="." mode="sql_write_conditions">
      <xsl:with-param name="indent" select="$indent_code" />
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="null_override" select="1" />
    </xsl:apply-templates>
    <xsl:value-of select="concat('END $$',$nl,$nl)" />
  </xsl:template>

  <xsl:template match="schema" mode="sql_write_proc_read">
    <xsl:variable name="prefix" select="'t'" />
    <xsl:variable name="type" select="'Read'" />

    <xsl:variable name="selline" select="concat($indent_code,'SELECT ')" />
    <xsl:variable name="indent_field">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="string-length($selline)" />
      </xsl:call-template>
    </xsl:variable>

    <!-- DROP and CREATE PROC -->
    <xsl:apply-templates select="." mode="sql_start_proc_with_id">
      <xsl:with-param name="type" select="$type" />
      <xsl:with-param name="indent" select="$indent_field" />
    </xsl:apply-templates>

    <!-- Procedure declaration -->
    <!-- SELECT fields -->
    <xsl:value-of select="$selline" />
    <xsl:if test="$prefix"><xsl:value-of select="concat($prefix,'.')" /></xsl:if>
    <xsl:value-of select="field[@primary_key]/@name" />
    <xsl:apply-templates select="field[not(@primary_key)]" mode="sql_write_selects">
      <xsl:with-param name="prefix" select="$prefix" />
      <xsl:with-param name="indent" select="$indent_field" />
    </xsl:apply-templates>
    <!-- FROM -->
    <xsl:value-of select="concat($nl,$indent_code,'  FROM ', $dbase,' ',$prefix,$nl)" />

    <!-- Condition -->
    <xsl:apply-templates select="." mode="sql_write_conditions">
      <xsl:with-param name="indent" select="$indent_code" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:value-of select="concat('END $$',$nl,$nl)" />
  </xsl:template>

  <xsl:template match="schema" mode="sql_write_proc_add">
    <xsl:apply-templates select="." mode="sql_start_proc_with_params">
      <xsl:with-param name="type" select="'Add'" />
      <xsl:with-param name="skip_id" select="1" />
    </xsl:apply-templates>

    <xsl:variable name="command_start" select="concat($indent_code,'INSERT INTO ',@name,' (')" />
    <xsl:variable name="command_start_len" select="string-length($command_start)" />

    <xsl:variable name="spaces_to_paren">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="$command_start_len" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat('BEGIN',$nl,$indent_code,'DECLARE newid INT UNSIGNED;',$nl,$nl)" />
    <xsl:value-of select="$command_start" />
    <xsl:apply-templates select="field[1]" mode="sql_add_proc_field">
      <xsl:with-param name="indent" select="$spaces_to_paren" />
    </xsl:apply-templates>
    <xsl:value-of select="concat(')',$nl)" />

    <xsl:variable name="values_start_len" select="($command_start_len)-string-length(@name)+6" />
    <xsl:variable name="spaces_to_val">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="$values_start_len" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="padstr">
      <xsl:with-param name="len" select="($values_start_len)-8" />
    </xsl:call-template>
    <xsl:text>VALUES (</xsl:text>
    <xsl:apply-templates select="field[1]" mode="sql_add_proc_field">
      <xsl:with-param name="indent" select="$spaces_to_val" />
    </xsl:apply-templates>

    <xsl:value-of select="concat(');',$nl)" />

    <xsl:call-template name="sql_if_row_count" />

    <xsl:value-of select="concat('END $$',$nl,$nl)" />

  </xsl:template>

  <xsl:template match="schema" mode="sql_write_proc_update">
    <xsl:param name="prefix" select="'t'" />

    <xsl:apply-templates select="." mode="sql_start_proc_with_params">
      <xsl:with-param name="type" select="'Update'" />
    </xsl:apply-templates>

    <xsl:variable name="command_start" select="concat($indent_code,'UPDATE ')" />

    <xsl:variable name="spaces_to_indent">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="string-length($command_start)" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat('BEGIN',$nl,$indent_code,'DECLARE newid INT UNSIGNED;',$nl,$nl)" />
    <xsl:value-of select="concat($command_start,@name,' ',$prefix)" />

    <xsl:apply-templates select="field[1]" mode="sql_update_set_field">
      <xsl:with-param name="indent" select="$spaces_to_indent" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:value-of select="$nl" />

    <!-- Condition -->
    <xsl:apply-templates select="." mode="sql_write_conditions">
      <xsl:with-param name="indent" select="$indent_code" />
      <xsl:with-param name="prefix" select="$prefix" />
    </xsl:apply-templates>

    <xsl:call-template name="sql_if_row_count" />

    <xsl:value-of select="concat('END $$',$nl,$nl)" />

  
  </xsl:template>

  <xsl:template match="schema" mode="sql">
    <xsl:value-of select="concat('DELIMITER $$',$nl)" />
    <xsl:apply-templates select="." mode="sql_write_proc_list" />
    <xsl:apply-templates select="." mode="sql_write_proc_read" />
    <xsl:apply-templates select="." mode="sql_write_proc_add" />
    <xsl:apply-templates select="." mode="sql_write_proc_update" />

    <xsl:value-of select="concat('DELIMITER ;',$nl)" />
  </xsl:template>
</xsl:stylesheet>
