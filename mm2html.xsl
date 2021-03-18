<?xml version="1.0" encoding="UTF-8" ?>

<!--
    MINDMAPEXPORTFILTER html;htm %xslt_export.html

    : This code released under the GPL.
    : (http://www.gnu.org/copyleft/gpl.html) Document : mindmap2html.xsl
    Created on : 01 February 2004, 17:17 Author : joerg feuerhake
    joerg.feuerhake@free-penguin.org Description: transforms freeplane mm
    format to html, handles crossrefs font declarations and colors. feel
    free to customize it while leaving the ancient authors mentioned.
    thank you ChangeLog: See: http://freeplane.sourceforge.net/
  -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--<xsl:output method="html" indent="no" encoding="ISO-8859-1" />-->
  <xsl:output method="html" indent="no" encoding="UTF-8" />

  <xsl:template match="/">
    <xsl:variable name="mapversion" select="map/@version" />
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>
        <!--<title><xsl:value-of select="map/node/@TEXT"/></title>-->
        <style>
          body{
          font-size:10pt;
          color:rgb(0,0,0);
          backgound-color:rgb(255,255,255);
          font-family:sans-serif;
          text-align: justify;
          text-justify: distribute;
          }
          p.info{
          font-size:8pt;
          text-align:right;
          color:rgb(127,127,127);
          }
          div.details{
          font-size: 8pt;
          color: #008000;
          background: #F8F8F8;
          padding: 2pt;
          }
          div.details > p{
          margin: 2pt 0;
          }
          pre {
          overflow-wrap: break-word;
          white-space: pre-wrap;
          }
          img {
          max-width: 600px;
          border: gray solid 2px;
          }
        </style>
      </head>
      <body>
        <xsl:apply-templates/>
        <p class="info">
          <xsl:value-of select="map/node/@TEXT"/>//mm2html.xsl FreeplaneVersion:<xsl:value-of select="$mapversion"/>
        </p>
      </body>
    </html>
  </xsl:template>

  <!-- clear content of hook -->
  <!--<hook NAME="MapStyle" background="#f0f5f5">-->
  <xsl:template match="hook[@NAME='MapStyle']"></xsl:template>
  <xsl:template match="node[@TREE_ID]"></xsl:template>

  <xsl:template match="node">
    <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="nodetext" select="@TEXT"/>
    <xsl:variable name="thisid" select="@ID"/>
    <xsl:variable name="thiscolor" select="@COLOR"/>
    <xsl:variable name="fontface" select="font/@NAME"/>
    <xsl:variable name="fontbold" select="font/@BOLD"/>
    <xsl:variable name="fontitalic" select="font/@ITALIC"/>
    <xsl:variable name="fontsize" select="font/@SIZE"/>
    <xsl:variable name="target" select="arrowlink/@DESTINATION"/>
    <ul><li>
    <xsl:attribute name="id">
      <xsl:value-of select="$thisid"/>
    </xsl:attribute>
    <xsl:if test="@STYLE_REF">
      <xsl:attribute name="class">
        <xsl:value-of select="translate(@STYLE_REF,' ','_')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@TEXT">
      <xsl:if test="arrowlink/@DESTINATION != ''">
        <a>
        <xsl:attribute name="style">
          <xsl:if test="$thiscolor != ''">
          <xsl:text>color:</xsl:text><xsl:value-of select="$thiscolor"/><xsl:text>;</xsl:text>
          </xsl:if>
          <xsl:if test="$fontface != ''">
          <xsl:text>font-family:</xsl:text><xsl:value-of select="translate($fontface,$ucletters,$lcletters)"/><xsl:text>;</xsl:text>
          </xsl:if>
          <xsl:if test="$fontsize != ''">
          <xsl:text>font-size:</xsl:text><xsl:value-of select="$fontsize"/><xsl:text>;</xsl:text>
          </xsl:if>
          <xsl:if test="$fontbold = 'true'">
          <xsl:text>font-weight:bold;</xsl:text>
          </xsl:if>
          <xsl:if test="$fontitalic = 'true'">
          <xsl:text>font-style:italic;</xsl:text>
          </xsl:if>
        </xsl:attribute>

        <xsl:attribute name="href">
          <xsl:text>#</xsl:text><xsl:value-of select="$target"/>
        </xsl:attribute>

        <xsl:value-of select="$nodetext"/>
        </a>
      </xsl:if>
      <xsl:if test="not(arrowlink/@DESTINATION)">
        <!--<div>-->
          <xsl:call-template name="tokenize">
            <xsl:with-param name="text" select="$nodetext"/>
          </xsl:call-template>
        <!--</div>-->
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
    </li></ul>
  </xsl:template>

  <xsl:template match="richcontent">
    <xsl:choose>
      <xsl:when test="@TYPE='DETAILS'">
        <div>
        <xsl:attribute name="class">details</xsl:attribute>
        <xsl:copy-of select = "./html/body/node()"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select = "./html/body/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="hook[@NAME='ExternalObject']">
      <img>
      <xsl:attribute name="src">
       <xsl:value-of select="@URI" disable-output-escaping="yes"/>
      </xsl:attribute>
      </img>
  </xsl:template>

  <xsl:template name="tokenize">
    <xsl:param name="text"/>
    <xsl:param name="delimiter" select="'&#10;'"/>
      <xsl:variable name="token" select="normalize-space(substring-before(concat($text, $delimiter), $delimiter))" />
      <xsl:if test="$token">
        <p>
          <xsl:value-of select="$token"/>
        </p>
      </xsl:if>
      <xsl:if test="contains($text, $delimiter)">
        <!-- recursive call -->
        <xsl:call-template name="tokenize">
          <xsl:with-param name="text" select="substring-after($text, $delimiter)"/>
        </xsl:call-template>
      </xsl:if>
  </xsl:template>
</xsl:stylesheet>
