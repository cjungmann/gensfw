<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" version="1.0" encoding="utf-8"/>

  <xsl:param name="dbase" select="'CaseStudy'" />
  <xsl:param name="mode" select="'sql'" />
  <xsl:param name="stem" select="'App_School_'" />
  <xsl:param name="includes" select="'id|name|city'" />

  <xsl:template name="padstr">
    <xsl:param name="len" />
    <xsl:text> </xsl:text>
    <xsl:if test="$len &gt; 1">
      <xsl:call-template name="padstr">
        <xsl:with-param name="len" select="($len)-1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:variable name="apos"><xsl:text>&apos;</xsl:text></xsl:variable>
  <xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>


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
    <xsl:variable name="l3" select="substring(@type, 2-string-length(@type))" />
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

  <xsl:template match="schema" mode="sql_add_params">
    <xsl:param name="str" />
    <xsl:param name="indent" />
    <xsl:param name="first" select="1" />

    <xsl:variable name="before" select="substring-before($str,'|')" />
    <xsl:variable name="blen" select="string-length($before)" />
    <xsl:variable name="after" select="substring($str,1 div boolean($blen=0))" />
    <xsl:variable name="name" select="concat($before,$after)" />

    <xsl:apply-templates select="field[@name=$name]" mode="sql_write_param" />

    <xsl:if test="$blen">
      <xsl:value-of select="concat(',',$nl,$indent)" />

      <xsl:apply-templates select="." mode="sql_add_params">
        <xsl:with-param name="str" select="substring-after($str,'|')" />
        <xsl:with-param name="indent" select="$indent" />
        <xsl:with-param name="first" select="0" />
      </xsl:apply-templates>
    </xsl:if>

  </xsl:template>

  <xsl:template match="schema" mode="sql_start_proc">
    <xsl:param name="type" />

    <xsl:value-of select="concat('DROP PROCEDURE IF EXISTS ',$stem,$type,'$$',$nl)" />

    <xsl:variable name="cp_string" select="concat('CREATE PROCEDURE ',$stem,$type,'(')" />
    <xsl:value-of select="$cp_string" />

    <xsl:apply-templates select="." mode="sql_add_params">
      <xsl:with-param name="str" select="$includes" />
      <xsl:with-param name="indent">
        <xsl:call-template name="padstr">
          <xsl:with-param name="len" select="string-length($cp_string)" />
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>

    <xsl:value-of select="concat(')',$nl)" />
  </xsl:template>


  <xsl:template match="schema" mode="sql_list_proc">
    <xsl:variable name="proc_name" select="concat($stem,'List')" />

    <xsl:apply-templates select="." mode="sql_start_proc">
      <xsl:with-param name="type" select="'List'" />
    </xsl:apply-templates>
    
  </xsl:template>

  <xsl:template match="schema" mode="sql">
    <xsl:value-of select="concat('DELIMITER $$',$nl)" />
    <xsl:apply-templates select="." mode="sql_list_proc" />

    <xsl:value-of select="concat('DELIMITER ;',$nl)" />
  </xsl:template>
</xsl:stylesheet>
