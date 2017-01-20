<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xd="http://www.pnp-software.com/XSLTdoc"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xd:doc type="stylesheet">
    <xd:short>
      Cette feuille permet de découper un fichier XML TEI Oriflamms en pages
      avant de procéder à la tokénisation au niveau de caractère.
    </xd:short>
    <xd:detail>
      This software is dual-licensed:
      
      1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
      Unported License http://creativecommons.org/licenses/by-sa/3.0/ 
      
      2. http://www.opensource.org/licenses/BSD-2-Clause
      
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without
      modification, are permitted provided that the following conditions are
      met:
      
      * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
      
      * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
      
      This software is provided by the copyright holders and contributors
      "as is" and any express or implied warranties, including, but not
      limited to, the implied warranties of merchantability and fitness for
      a particular purpose are disclaimed. In no event shall the copyright
      holder or contributors be liable for any direct, indirect, incidental,
      special, exemplary, or consequential damages (including, but not
      limited to, procurement of substitute goods or services; loss of use,
      data, or profits; or business interruption) however caused and on any
      theory of liability, whether in contract, strict liability, or tort
      (including negligence or otherwise) arising in any way out of the use
      of this software, even if advised of the possibility of such damage.
      
      $Id$
      
      This stylesheet is based on TEI processpb.xsl by Sebastian Rahtz 
      available at 
      https://github.com/TEIC/Stylesheets/blob/master/tools/processpb.xsl 
      and is adapted by Alexei Lavrentiev to split an XML TEI Oriflamms file
      into pages for further tokenizatrion at character level.
      
    </xd:detail>
    <xd:author>Alexei Lavrentiev alexei.lavrentev@ens-lyon.fr</xd:author>
    <xd:copyright>2015, CNRS / ICAR (Équipe CACTUS)</xd:copyright>
  </xd:doc>
  
  
  
  <xsl:output indent="no" method="xml"/>


  <xsl:variable name="filename">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:variable name="filedir">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)\.[^/]+$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <!--<xsl:variable name="filenameresult">
    <xsl:value-of select="replace($filename,'(-ori)?-w$','')"/>
  </xsl:variable>-->

  <xsl:param name="output-directory"><xsl:value-of select="concat($filedir,'/out')"/></xsl:param>

 
  <xsl:template match="teiHeader">
    <!--<xsl:copy-of select="."/>-->
  </xsl:template>
  
  <xsl:template match="TEI|teiCorpus|group|text">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="text/body|text/back|text/front">
      <xsl:variable name="pages">
	<xsl:copy>
	  <xsl:apply-templates select="@*"/>
	  <xsl:apply-templates
	      select="*|processing-instruction()|comment()|text()"/>
	</xsl:copy>
      </xsl:variable>
      <xsl:for-each select="$pages">
	<xsl:apply-templates  mode="pass2"/>
      </xsl:for-each>
  </xsl:template>


 <!-- first (recursive) pass. look for <pb> elements and group on them -->
  <xsl:template match="comment()|@*|processing-instruction()|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:call-template name="checkpb">
      <xsl:with-param name="eName" select="local-name()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="milestone[@unit='surface']">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template name="checkpb">
    <xsl:param name="eName"/>
    <xsl:choose>
      <xsl:when test="not(.//milestone[@unit='surface'])">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pass">
	  <xsl:call-template name="groupbypb">
	    <xsl:with-param name="Name" select="$eName"/>
	  </xsl:call-template>
        </xsl:variable>
	<xsl:for-each select="$pass">
	  <xsl:apply-templates/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="groupbypb">
    <xsl:param name="Name"/>
    <xsl:for-each-group select="node()" group-starting-with="milestone[@unit='surface']">
      <xsl:choose>
        <xsl:when test="self::milestone[@unit='surface']">
          <xsl:copy-of select="."/>
          <xsl:element name="{$Name}" namespace="http://www.w3.org/1999/xhtml">
	    <xsl:attribute name="rend">CONTINUED</xsl:attribute>
            <xsl:apply-templates select="current-group() except ."/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="{$Name}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:for-each select="..">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="current-group()"/>
            </xsl:for-each>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <!-- second pass. group by <pb> (now all at top level) and wrap groups
       in <page> -->
  <xsl:template match="*" mode="pass2">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" mode="pass2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|@*|processing-instruction()|text()" mode="pass2">
    <xsl:copy-of select="."/>
  </xsl:template>


  <xsl:template match="*[milestone[@unit='surface']]" mode="pass2" >
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:for-each-group select="*" group-starting-with="milestone[@unit='surface']">
        <xsl:choose>
          <xsl:when test="self::milestone[@unit='surface']">
          	<xsl:comment> Page <xsl:value-of select="@xml:id"/> enregistrée dans <xsl:value-of select="concat($output-directory,'/',$filename,'_',@xml:id,'.xml')"/></xsl:comment>
            <xsl:text>&#xA;</xsl:text>
          	<xsl:result-document href="{$output-directory}/{$filename}_{@xml:id}.xml" indent="yes">
          	<TEI>
          	  <teiHeader>
          	    <fileDesc>
          	      <titleStmt>
          	        <title>Page <xsl:value-of select="@xml:id"/> of <xsl:value-of select="$filename"/> tokenized at character level.</title>
          	      </titleStmt>
          	      <publicationStmt>
          	        <p>Oriflamms project (http://oriflamms.hypotheses.org)</p>
          	      </publicationStmt>
          	      <sourceDesc>
          	        <p>Converted from <xsl:value-of select="$filename"/>.</p>
          	      </sourceDesc>
          	    </fileDesc>
          	    <revisionDesc>
          	      <change when="{current-dateTime()}">File created.</change>
          	    </revisionDesc>
          	  </teiHeader>
          	  <text>
          	    <body>
          	      <xsl:copy-of select="."/>
        	        <xsl:copy-of select="current-group() except ."/>
          	    </body>
          	  </text>
          	</TEI>
          	</xsl:result-document>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
