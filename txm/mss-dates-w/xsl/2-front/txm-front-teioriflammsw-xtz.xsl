<?xml version="1.0"?>
<xsl:stylesheet xmlns:edate="http://exslt.org/dates-and-times"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:me="http://www.menota.org/ns/1.0"
  xmlns:bfm="http://bfm.ens-lsh.fr/ns/1.0"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  exclude-result-prefixes="tei edate bfm me" version="2.0">

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no"/>
  

  <xd:doc type="stylesheet">
    <xd:short>
      Cette feuille XSLT prépare les fichiers au format TEI Oriflamms
      (tokénisés par mot) à l'imppportation dans TXM avec le module XTZ
      (étape 2 "front").
    </xd:short>
    <xd:detail>
      This stylesheet is free software; you can redistribute it and/or
      modify it under the terms of the GNU Lesser General Public
      License as published by the Free Software Foundation; either
      version 3 of the License, or (at your option) any later version.
      
      This stylesheet is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
      Lesser General Public License for more details.
      
      You should have received a copy of GNU Lesser Public License with
      this stylesheet. If not, see http://www.gnu.org/licenses/lgpl.html
    </xd:detail>
    <xd:author>Alexei Lavrentiev alexei.lavrentev@ens-lyon.fr</xd:author>
    <xd:copyright>2016, CNRS / ICAR (Équipe CACTUS)</xd:copyright>
  </xd:doc>
  

  <xsl:template match="*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="comment()|processing-instruction()|text()|@*">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="comment()|processing-instruction()|@*" mode="expan letters-all 
    letters-alignable characters-alignable">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="filename">
    <xsl:analyze-string select="document-uri(.)" regex="^(.*)/([^/]+)-w\.xml$">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  
  <xsl:template match="tei:facsimile"/>
  
<xsl:template match="tei:teiCorpus">
  <TEI xmlns="http://www.tei-c.org/ns/1.0">
    <text>
      <!-- on ajoute des attributs utiles pour la création de partitions et de sous-corpus -->
      <xsl:apply-templates/>
    </text>
  </TEI>
</xsl:template>


<xsl:template match="tei:TEI[ancestor::tei:teiCorpus]">
<xsl:apply-templates/>
</xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <!--<xsl:copy-of select="."/>-->
  </xsl:template>
  
  <xsl:template match="tei:text[not(ancestor::tei:teiCorpus)]">
    <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
      <!-- on ajoute des attributs utiles pour la création de partitions et de sous-corpus -->
      <xsl:apply-templates select="@*"/>
     <xsl:apply-templates/> 
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tei:text[ancestor::tei:teiCorpus]">
    <div type="text" id="{$filename}-{count(preceding::tei:text) + 1}" xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>

<xsl:template match="tei:milestone[@unit='surface']">
  <pb xmlns="http://www.tei-c.org/ns/1.0" n="{following::tei:pb[1]/@n}" facs="{@facs}" xml:id="{@xml:id}"/>
</xsl:template>
  
  <xsl:template match="tei:pb">
    <milestone unit="ms-page">
      <xsl:apply-templates select="@*"/>
    </milestone>
  </xsl:template>

<xsl:template match="tei:w[not(tei:seg[@type='wp'])]">
  <xsl:element name="w" namespace="http://www.tei-c.org/ns/1.0">
    <xsl:apply-templates select="@*"/>
    <xsl:attribute name="expan"><xsl:apply-templates mode="expan"/></xsl:attribute>
    <xsl:attribute name="letters-all"><xsl:apply-templates mode="letters-all"/></xsl:attribute>
    <xsl:attribute name="letters-alignable"><xsl:apply-templates mode="letters-alignable"/></xsl:attribute>
    <xsl:attribute name="characters"><xsl:apply-templates mode="characters-alignable"/></xsl:attribute>
    <xsl:attribute name="abbr-n">
      <xsl:choose>
        <xsl:when test="descendant::tei:abbr">
          <xsl:value-of select="count(descendant::tei:abbr)"/>
        </xsl:when>
        <xsl:when test="descendant::tei:expan">
          <xsl:value-of select="count(descendant::tei:expan)"/>
        </xsl:when>
        <xsl:when test="descendant::tei:ex">
          <xsl:value-of select="count(descendant::tei:ex)"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="ref"><xsl:value-of select="concat($filename,', f. ',preceding::tei:pb[1]/@n,', col. ',preceding::tei:cb[1]/@n,', l. ',preceding::tei:lb[1]/@n)"/></xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>
  
  <xsl:template match="tei:w[tei:seg[@type='wp']]">
    <xsl:element name="w-lb" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="expan"><xsl:apply-templates mode="expan"/></xsl:attribute>
      <xsl:attribute name="letters-all"><xsl:apply-templates mode="letters-all"/></xsl:attribute>
      <xsl:attribute name="letters-alignable"><xsl:apply-templates mode="letters-alignable"/></xsl:attribute>
      <xsl:attribute name="characters"><xsl:apply-templates mode="characters-alignable"/></xsl:attribute>
      <xsl:attribute name="abbr-n">
        <xsl:choose>
          <xsl:when test="descendant::tei:abbr">
            <xsl:value-of select="count(descendant::tei:abbr)"/>
          </xsl:when>
          <xsl:when test="descendant::tei:expan">
            <xsl:value-of select="count(descendant::tei:expan)"/>
          </xsl:when>
          <xsl:when test="descendant::tei:ex">
            <xsl:value-of select="count(descendant::tei:ex)"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="ref"><xsl:value-of select="concat($filename,', f. ',preceding::tei:pb[1]/@n,', col. ',preceding::tei:cb[1]/@n,', l. ',preceding::tei:lb[1]/@n)"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tei:seg[@type='wp']">
    <xsl:element name="w" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="expan"><xsl:apply-templates mode="expan"/></xsl:attribute>
      <xsl:attribute name="letters-all"><xsl:apply-templates mode="letters-all"/></xsl:attribute>
      <xsl:attribute name="letters-alignable"><xsl:apply-templates mode="letters-alignable"/></xsl:attribute>
      <xsl:attribute name="characters"><xsl:apply-templates mode="characters-alignable"/></xsl:attribute>
      <xsl:attribute name="abbr-n">
        <xsl:value-of select="count(descendant::tei:abbr)"/>
      </xsl:attribute>
      <xsl:attribute name="ref"><xsl:value-of select="concat($filename,', f. ',preceding::tei:pb[1]/@n,', col. ',preceding::tei:cb[1]/@n,', l. ',preceding::tei:lb[1]/@n)"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tei:pc[not(child::tei:reg or @ana='ori:align-no')]">
    <xsl:element name="w" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="type">pc</xsl:attribute>
      <xsl:attribute name="expan"><xsl:apply-templates/></xsl:attribute>
      <xsl:attribute name="letters-all"><xsl:apply-templates mode="letters-all"/></xsl:attribute>
      <xsl:attribute name="letters-alignable"><xsl:apply-templates mode="letters-alignable"/></xsl:attribute>
      <xsl:attribute name="characters"><xsl:apply-templates mode="characters-alignable"/></xsl:attribute>
      <xsl:attribute name="abbr-n">
        <xsl:value-of select="0"/>
      </xsl:attribute>
      <xsl:attribute name="ref"><xsl:value-of select="concat($filename,', f. ',preceding::tei:pb[1]/@n,', col. ',preceding::tei:cb[1]/@n,', l. ',preceding::tei:lb[1]/@n)"/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tei:pc[child::tei:reg or @ana='ori:align-no']">
    <xsl:comment><xsl:copy-of select="."/></xsl:comment>
  </xsl:template>

  <xsl:template match="tei:choice[tei:abbr]">
    <xsl:apply-templates select="tei:abbr"/>
  </xsl:template>
  
  <xsl:template match="tei:choice[tei:abbr]" mode="expan">
    <xsl:apply-templates select="tei:expan" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="tei:choice[tei:abbr]" mode="letters-all">
    <xsl:apply-templates select="tei:expan" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="tei:choice[tei:abbr]" mode="letters-alignable">
    <xsl:choose>
      <xsl:when test="tei:expan[tei:ex]">
        <xsl:apply-templates select="tei:expan" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="tei:abbr" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:choice[tei:abbr]" mode="characters-alignable">
    <xsl:apply-templates select="tei:abbr" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="tei:choice[tei:orig]" mode="#all">
    <xsl:apply-templates select="tei:orig" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="tei:abbr" mode="letters-alignable">
    <xsl:apply-templates select="descendant::text()" mode="letters-alignable"/>
  </xsl:template>
  
  <xsl:template match="tei:reg" mode="#all"></xsl:template>
  
  <xsl:template match="tei:orig" mode="#all">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="tei:ex" mode="expan">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:ex" mode="letters-all">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="tei:ex" mode="letters-alignable"/>
  
  <xsl:template match="tei:ex" mode="characters-alignable">
    <xsl:choose>
      <xsl:when test="matches(.,'^(cum|com|con)$','i')">&#xA76F;</xsl:when>
      <xsl:when test="matches(.,'^et$','i')">&#x204A;</xsl:when>
      <xsl:when test="matches(.,'^est$','i')">&#x223B;</xsl:when>
      <xsl:when test="matches(.,'^us$','i')">&#xA770;</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:supplied"></xsl:template>
  
  
  <xsl:template match="text()" mode="expan letters-all">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>


<xsl:template match="tei:w//text()" mode="characters-alignable">
  <xsl:analyze-string select="." regex="\p{{M}}|\s">
    <xsl:matching-substring/>
    <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
  </xsl:analyze-string>
</xsl:template>
  
  <xsl:template match="tei:w//text()" mode="letters-alignable">
    <xsl:analyze-string select="." regex=".">
      <xsl:matching-substring>
        <xsl:choose>
          <xsl:when test="matches(.,'\p{M}|\s')"></xsl:when>
          <xsl:when test="matches(.,$alignable-abbreviation-marks)"/>
          <xsl:when test="matches(.,$modified-letters)">
            <xsl:call-template name="modified-letters"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <xsl:variable name="modified-letters">^(&#x0141;|&#x0142;|[&#xA748;-&#xA759;])$</xsl:variable>
  <xsl:variable name="alignable-abbreviation-marks">^(&amp;|&#x204A;|&#x2079;|&#x223B;|&#xA76F;|&#xA770;|&#xF1A6;|&#xF1AC;)$</xsl:variable>
  
  <xsl:template name="modified-letters">
    <xsl:choose>
      <xsl:when test="matches(.,'&#x0141;|&#xA748;')">L</xsl:when>
      <xsl:when test="matches(.,'&#x0142;|&#xA749;')">l</xsl:when>
      <xsl:when test="matches(.,'&#xA750;|&#xA752;|&#xA754;')">P</xsl:when>
      <xsl:when test="matches(.,'&#xA751;|&#xA753;|&#xA755;')">p</xsl:when>
      <xsl:when test="matches(.,'&#xA756;|&#xA758;')">Q</xsl:when>
      <xsl:when test="matches(.,'&#xA757;|&#xA759;')">q</xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
