<?xml version="1.0" encoding="utf-8" ?>

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="utf-8"/>

  <xsl:variable name="nl" select="'&#10;'" />
  <xsl:variable name="apos">'</xsl:variable>

  <xsl:variable name="index_column"
                select="/resultset/row[string-length(field[@name='COLUMN_KEY'])&gt;0]" />
  <xsl:variable
      name="index_column_name" select="$index_column/field[@name='COLUMN_NAME']" />

  <xsl:variable name="rows" select="/resultset/row[string-length(field[@name='COLUMN_KEY'])=0]" />

  <xsl:variable name="table_name">
    <xsl:call-template name="parse_statement">
      <xsl:with-param name="aname" select="'TABLE_NAME'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="dbase_name">
    <xsl:call-template name="parse_statement">
      <xsl:with-param name="aname" select="'TABLE_SCHEMA'" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="lcase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="ucase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:template name="parse_statement">
    <xsl:param name="aname" />
    <xsl:variable name="filter" select="concat($aname,'=',$apos)" />
    <xsl:variable name="after" select="substring-after(/resultset/@statement,$filter)" />
    <xsl:value-of select="substring-before($after,$apos)" />
  </xsl:template>

  <xsl:template name="spacify">
    <xsl:param name="str" />
    <xsl:text> </xsl:text>
    <xsl:if test="string-length($str) &gt; 1">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="substring($str,2)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="row" mode="get_data_type">
    <xsl:value-of select="translate(field[@name='COLUMN_TYPE'],$lcase,$ucase)" />
  </xsl:template>

  <xsl:template match="row" mode="null">
    <xsl:text>NULL</xsl:text>
    <xsl:if test="not(position()=last())">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="row" mode="raw">
    <xsl:param name="indent" select="''" />

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="concat(',',$nl,$indent)" />
    </xsl:if>

    <xsl:value-of select="field[@name='COLUMN_NAME']" />
  </xsl:template>

  <xsl:template match="row" mode="ticked">
    <xsl:param name="indent" select="''" />

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="concat(',',$nl,$indent)" />
    </xsl:if>

    <xsl:value-of select="concat('`',field[@name='COLUMN_NAME'],'`')" />
  </xsl:template>


  <xsl:template match="row" mode="self-set">
    <xsl:param name="indent" select="''" />

    <xsl:variable name="name" select="field[@name='COLUMN_NAME']" />

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="concat(',',$nl,$indent)" />
    </xsl:if>

    <xsl:value-of select="concat('`',$name,'` = ', $name)" />
  </xsl:template>

  <xsl:template match="row" mode="add_parameter">
    <xsl:param name="indent" select="''" />

    <xsl:variable name="name" select="field[@name='COLUMN_NAME']" />
    <xsl:variable name="type">
      <xsl:apply-templates select="." mode="get_data_type" />
    </xsl:variable>

    <xsl:if test="position() &gt; 1"><xsl:value-of select="concat(',',$nl,$indent)" /></xsl:if>
    <xsl:value-of select="concat($name, ' ', $type)" />
  </xsl:template>

  <xsl:template match="row" mode="sessionize">
    <xsl:param name="indent" select="''" />

    <xsl:if test="position() &gt; 1">
      <xsl:value-of select="concat(',',$nl,$indent)" />
    </xsl:if>

    <xsl:value-of select="concat('@session_', field[@name='COLUMN_NAME'])" />
  </xsl:template>

  <xsl:template match="row" mode="set_sessions">
  </xsl:template>



  <xsl:template match="resultset" mode="cleanup">
    <xsl:variable name="indent">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="'    SELECT'" />
      </xsl:call-template>
    </xsl:variable>
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Cleanup $$
CREATE PROCEDURE App_Session_Cleanup()
BEGIN
   SELECT <xsl:apply-templates select="$rows" mode="null" />
     INTO <xsl:apply-templates select="$rows" mode="sessionize">
   <xsl:with-param name="indent" select="$indent" />
 </xsl:apply-templates>;

END $$
  </xsl:template>

  <xsl:template match="resultset" mode="start">
-- ------------------------------------------
-- System Session Procedure Override
-- ------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Start $$
CREATE PROCEDURE App_Session_Start(session_id INT UNSIGNED)
BEGIN
   INSERT INTO <xsl:value-of select="$table_name" />(<xsl:value-of select="$index_column_name" />)
          VALUES(session_id);
END $$
  </xsl:template>


  <xsl:template match="resultset" mode="restore">
    <xsl:variable name="indent">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="'    SELECT'" />
      </xsl:call-template>
    </xsl:variable>
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Restore $$
CREATE PROCEDURE App_Session_Restore(session_id INT UNSIGNED)
BEGIN
   SELECT <xsl:apply-templates select="$rows" mode="raw">
   <xsl:with-param name="indent" select="$indent" />
 </xsl:apply-templates>
     INTO <xsl:apply-templates select="$rows" mode="sessionize">
   <xsl:with-param name="indent" select="$indent" />
 </xsl:apply-templates>
     FROM <xsl:value-of select="$table_name" />
    WHERE <xsl:value-of select="$index_column_name" /> = session_id;
END $$
  </xsl:template>

  <xsl:template match="resultset" mode="abandon">
-- --------------------------------------------
-- System Session Procedure Override
-- --------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Abandon $$
CREATE PROCEDURE App_Session_Abandon(session_id INT UNSIGNED)
BEGIN
   DELETE FROM <xsl:value-of select="$table_name" />
      WHERE <xsl:value-of select="$index_column_name" /> = session_id;
END $$
  </xsl:template>


  <xsl:template match="row" mode="set_function">
    <xsl:variable name="cname" select="field[@name='COLUMN_NAME']" />
    <xsl:variable name="pname" select="concat('App_Session_Set_', $cname)" />
    <xsl:variable name="pspaced">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="$pname" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ptype">
      <xsl:apply-templates select="." mode="get_data_type" />
    </xsl:variable>
-- ------------------------<xsl:value-of select="translate($pspaced,' ','-')" />
-- Sets the persistent &apos;<xsl:value-of select="$cname" />&apos; session value.
-- ------------------------<xsl:value-of select="translate($pspaced,' ','-')" />
DROP PROCEDURE IF EXISTS <xsl:value-of select="$pname" /> $$
CREATE PROCEDURE <xsl:value-of select="$pname" />(val <xsl:value-of select="$ptype" />)
BEGIN
   SET @session_<xsl:value-of select="$cname" /> = val;
   UPDATE <xsl:value-of select="$table_name" />
      SET <xsl:value-of select="$cname" /> = val
    WHERE <xsl:value-of select="$index_column_name" /> = @session_confirmed_id;
END $$
  </xsl:template>


  <xsl:template match="resultset" mode="initialize_session">
    <xsl:variable name="create_string" select="'CREATE PROCEDURE App_Session_Initialize('" />
    <xsl:variable name="param_indent">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="$create_string" />
      </xsl:call-template>
    </xsl:variable>

    <!-- field and value alignment variables -->
    <xsl:variable name="set_str" select="'      SET '" />
    <xsl:variable name="set_indent">
      <xsl:call-template name="spacify">
        <xsl:with-param name="str" select="$set_str" />
      </xsl:call-template>
    </xsl:variable>
-- -----------------------------------------------
-- Call this procedure at a successful login
-- -----------------------------------------------
DROP PROCEDURE IF EXISTS App_Session_Initialize $$
<xsl:value-of select="$create_string" /><xsl:apply-templates select="$rows" mode="add_parameter">
<xsl:with-param name="indent" select="$param_indent" />
</xsl:apply-templates>)
BEGIN
   UPDATE <xsl:value-of select="$table_name" />
<xsl:value-of select="concat($nl,$set_str)" />
<xsl:apply-templates select="$rows" mode="self-set">
  <xsl:with-param name="indent" select="$set_indent" />
</xsl:apply-templates>
    WHERE <xsl:value-of select="concat('`',$index_column_name,'` = @session_confirmed_id;')" />
END $$
  </xsl:template>

  
  <xsl:template match="/">
USE <xsl:value-of select="$dbase_name" />;
DELIMITER $$
    <xsl:apply-templates select="resultset" mode="cleanup" />
    <xsl:apply-templates select="resultset" mode="start" />
    <xsl:apply-templates select="resultset" mode="restore" />
    <xsl:apply-templates select="resultset" mode="abandon" />

    <xsl:apply-templates select="resultset" mode="initialize_session" />

    <xsl:apply-templates select="$rows" mode="set_function" />
DELIMITER ;
  </xsl:template>



</xsl:stylesheet>
