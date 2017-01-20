<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">
	<!--
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
and is adapted by Alexei Lavrentiev to split an HTML edition for 
TXM platform.

  -->
	<xsl:output indent="no" method="xml"/>
	
	  <xsl:param name="css-name-txm">txm</xsl:param>
	  <xsl:param name="css-name">tei</xsl:param>
	  <xsl:param name="edition-name">facs</xsl:param>
	  <xsl:param name="number-words-per-page">999999</xsl:param>
	  <xsl:param name="pagination-element">pb</xsl:param>
	  <xsl:param name="output-directory">
      <xsl:value-of select="concat($current-file-directory,'/',$edition-name)"/>
   </xsl:param>
	  <xsl:param name="image-directory">/home/alavrent/Bureau/Oriflamms_sources/mss-dates/mss-dates/img</xsl:param>
	  <xsl:param name="word-element">w</xsl:param>
	
	  <!-- /home/alavrent/Bureau/Oriflamms_sources/mss-dates/mss-dates/img -->
	
	<xsl:variable name="current-file-name">
		    <xsl:analyze-string regex="^(.*)/([^/]+)\.[^/]+$" select="document-uri(.)">
			      <xsl:matching-substring>
				        <xsl:value-of select="regex-group(2)"/>
			      </xsl:matching-substring>
		    </xsl:analyze-string>
	  </xsl:variable>
	
	  <xsl:variable name="current-file-directory">
		    <xsl:analyze-string regex="^(.*)/([^/]+)\.[^/]+$" select="document-uri(.)">
			      <xsl:matching-substring>
				        <xsl:value-of select="regex-group(1)"/>
			      </xsl:matching-substring>
		    </xsl:analyze-string>
	  </xsl:variable>
	
	  <xsl:variable as="xs:integer" name="page-number-adjust">
		    <xsl:choose>
			      <xsl:when test="$word-element='c'">1</xsl:when>
			      <xsl:otherwise>2</xsl:otherwise>
		    </xsl:choose>
	  </xsl:variable>
	
	
	
	  <xsl:template match="/">
		    <dummy>
         <xsl:apply-templates select="descendant::*[local-name()=$pagination-element]"/>
      </dummy>
		    <xsl:if test="$word-element='w'">
			      <xsl:result-document href="{$output-directory}/{$current-file-name}_1.html">
				        <html>
					          <head>
						            <meta content="w_0" name="txm:first-word-id"/>
						            <title>
                     <xsl:value-of select="concat($current-file-name,', Page de garde')"/>
                  </title>
						            <meta content="text/html;charset=UTF-8" http-equiv="Content-Type"/>
						            <link href="css/{$css-name-txm}.css"
                        media="all"
                        rel="stylesheet"
                        type="text/css"/>
						            <xsl:if test="matches($css-name,'\S')">
                     <link href="css/{$css-name}.css"
                           media="all"
                           rel="stylesheet"
                           type="text/css"/>
                  </xsl:if>
						            <!--<xsl:copy-of select="$style"/>-->
					</head>
					          <body>
						            <div class="txmeditionpage">
							              <h2>
                        <xsl:value-of select="$current-file-name"/>
                     </h2>
							              <h3>Reproductions des pages</h3>
							
						            </div>
					          </body>
				        </html>
			      </xsl:result-document>			
		    </xsl:if>		
	  </xsl:template>
	
	
	  <xsl:template match="*[local-name()=$pagination-element]">
		    <xsl:variable as="xs:integer" name="next-word-position">
			      <xsl:choose>
				        <xsl:when test="following::*[local-name()=$word-element]">
					          <xsl:value-of select="count(following::*[local-name()=$word-element][1]/preceding::*[local-name()=$word-element])"/>
				        </xsl:when>
				        <xsl:otherwise>0</xsl:otherwise>
			      </xsl:choose>
		    </xsl:variable>
		    <xsl:variable as="xs:integer" name="next-pb-position">
			      <xsl:choose>
				        <xsl:when test="following::*[local-name()=$pagination-element]">
					          <xsl:value-of select="count(following::*[local-name()=$pagination-element][1]/preceding::*[local-name()=$word-element])"/>
				        </xsl:when>
				        <xsl:otherwise>999999999</xsl:otherwise>
			      </xsl:choose>
		    </xsl:variable>
		    <xsl:variable name="next-word-id">
			      <xsl:choose>
				        <xsl:when test="$next-pb-position - $next-word-position = 999999999">w_0</xsl:when>
				        <xsl:when test="$next-pb-position &gt; $next-word-position">
               <xsl:value-of select="following::*[local-name()=$word-element][1]/@id"/>
            </xsl:when>
				        <xsl:otherwise>w_0</xsl:otherwise>
			      </xsl:choose>
		    </xsl:variable>
		    <xsl:variable name="pageId">
         <xsl:value-of select="@id"/>
      </xsl:variable>
						<xsl:comment> Page <xsl:value-of select="@id"/> enregistrée dans <xsl:value-of select="concat($output-directory,'/',$current-file-name,'_',count(preceding::*[local-name()=$pagination-element]) + $page-number-adjust,'.html')"/>
      </xsl:comment>
		    <xsl:result-document href="{$output-directory}/{$current-file-name}_{count(preceding::*[local-name()=$pagination-element]) + $page-number-adjust}.html">
							  <html>
								    <head>
									      <meta content="{$next-word-id}" name="txm:first-word-id"/>
									      <title>
                  <xsl:value-of select="concat($current-file-name,', Page ',@n)"/>
               </title>
									      <meta content="text/html;charset=UTF-8" http-equiv="Content-Type"/>
									      <link href="css/{$css-name-txm}.css"
                     media="all"
                     rel="stylesheet"
                     type="text/css"/>
									      <xsl:if test="matches($css-name,'\S')">
                  <link href="css/{$css-name}.css"
                        media="all"
                        rel="stylesheet"
                        type="text/css"/>
               </xsl:if>
									      <script src="js/viewer/Simple_Viewer_beta_1.1-min.js" type="text/javascript">
                  <xsl:text> </xsl:text>
               </script>
									      <script src="js/viewer/toolbar-ext.js" type="text/javascript">
                  <xsl:text> </xsl:text>
               </script>
									      <link href="js/viewer/toolbar-ext.css" rel="stylesheet" type="text/css"/>
									      <!--<xsl:copy-of select="$style"/>-->
								</head>
								    <body>
									      <div class="txmeditionpage">
										        <img alt="Image {@id} indisponible"
                       onLoad="viewer.toolbarImages='images/icons';viewer.onload=viewer.toolbar;new viewer({{image: this, frame: ['100%','100%']}});"
                       src="{$image-directory}/{@facs}"/>
										        <!--<span class="invisible" id="{following::tei:w[1]/@id}"></span>-->
										<span class="invisible" id="{$next-word-id}"/>
										
									      </div>
								    </body>
							  </html>
						</xsl:result-document>
						
	  </xsl:template>
	
		
</xsl:stylesheet>
