<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright 2020 Karl-Johan Grahn -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <xsl:output method="html" encoding="utf-8" indent="yes"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>Log Parsing Report</title>
        <link href="styling.css" rel="stylesheet" type="text/css" />
      </head>
      <body>
        <xsl:apply-templates select="//target"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="target">
    <xsl:apply-templates select="name"/>
    <xsl:apply-templates select="issues"/>
    <xsl:apply-templates select="processed_files"/>
    <xsl:apply-templates select="generated_files"/>
  </xsl:template>

  <xsl:template match="name">
    <h1>
      Build Target: <xsl:value-of select="."/>
    </h1>
  </xsl:template>

  <xsl:template match="issues">
    <xsl:if test="issue">
      <h2>Build Issues:</h2>
      <ul>
        <xsl:apply-templates select="issue"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="issue">
    <li class="issue">
      <xsl:value-of select="."/>
    </li>
  </xsl:template>

  <xsl:template match="processed_files">
    <xsl:if test="file">
      <h2>Processed source files:</h2>
      <ul>
        <xsl:apply-templates select="file"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="generated_files">
    <xsl:if test="file">
      <h2>Generated target files:</h2>
      <ul>
        <xsl:apply-templates select="file"/>
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="file">
    <li>
      <xsl:value-of select="."/>
    </li>
  </xsl:template>

</xsl:stylesheet>