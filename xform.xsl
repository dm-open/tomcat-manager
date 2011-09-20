<?xml version="1.0"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Output method -->
  <xsl:output encoding="utf8" indent="yes"/>

  <xsl:template match="status">
    <html>
    <head>
    	<title>Tomcat Status: <xsl:value-of select="connector/@name"/></title>
    	<link rel="stylesheet" href="/manager/css/layout.css"/>
    </head>
    <body>
		<section class="status">
			<h1><xsl:value-of select="connector/@name"/></h1>
			<xsl:variable name="free" select="number(jvm/memory/@free)"/>
			<xsl:variable name="total" select="number(jvm/memory/@max)"/>
			<div>
				<xsl:attribute name="class">
					indicator ratio memory
					<xsl:choose>
						<xsl:when test="$free &lt; ($total div 5)">warn</xsl:when>
						<xsl:when test="$free &lt; ($total div 10)">error</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<h5>Memory Usage</h5>
				<span class="value"><xsl:value-of select="format-number(number(jvm/memory/@free) div 1000000, '#')"/></span>
				<span class="from">/ <xsl:value-of select="format-number(number(jvm/memory/@total) div 1000000, '#')"/> <abbr>MB</abbr></span>
			</div>
			<xsl:variable name="busy" select="number(connector/threadInfo/@currentThreadsBusy)"/>
			<xsl:variable name="threads" select="number(connector/threadInfo/@maxThreads)"/>
			<div>
				<xsl:attribute name="class">
					indicator ratio threads
					<xsl:choose>
						<xsl:when test="$busy &gt; ($threads div 3)">warn</xsl:when>
						<xsl:when test="$busy &gt; ($threads div 2)">error</xsl:when>
						<xsl:when test="$busy &gt; ($threads div 1.5)">help</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<h5>Busy Threads</h5>
				<span class="value"><xsl:value-of select="connector/threadInfo/@currentThreadsBusy"/></span>
				<span class="from">/ <xsl:value-of select="connector/threadInfo/@maxThreads"/></span>
			</div>
			<div class="indicator max">
				<h5>Peak Memory</h5>
				<span class="value"><xsl:value-of select="format-number(number(jvm/memory/@max) div 1000000, '#')"/> <abbr>MB</abbr></span>
			</div>
			<div class="indicator max">
				<h5>Peak Threads</h5>
				<span class="value"><xsl:value-of select="connector/threadInfo/@currentThreadCount"/></span>
			</div>
			<div class="indicator traffic">
				<h5>Sent / Received</h5>
				<span class="value">
					<xsl:value-of select="format-number(number(connector/requestInfo/@bytesSent) div 1000000, '#')"/> /
					<xsl:value-of select="format-number(number(connector/requestInfo/@bytesReceived) div 1000000, '#')"/> <abbr>MB</abbr>
				</span>
			</div>
			<div>
				<xsl:variable name="errors" select="(number(connector/requestInfo/@errorCount) div number(connector/requestInfo/@requestCount)) * 100"/>
				<xsl:attribute name="class">
					indicator errors
					<xsl:choose>
						<xsl:when test="$errors &gt; 5">error</xsl:when>
						<xsl:when test="$errors &gt; 1">warn</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<h5>Requests / Errors</h5>
				<span class="value">
					<xsl:value-of select="format-number(number(connector/requestInfo/@requestCount), '#,###,###')"/> /</span>
				<span class="errors">
					<xsl:value-of select="format-number($errors, '#0.00')"/>%
				</span>
			</div>
		</section>

		<xsl:apply-templates select="connector"/>
     </body>
    </html>
  </xsl:template>

  <xsl:template match="connector">
  	<h2><strong>Connector: </strong><xsl:value-of select="@name"/></h2>
  	<xsl:apply-templates select="workers"/>
  </xsl:template>

  <xsl:template match="workers">
   <table class="threads">
    <tr>
    	<th class="url">URL</th>
    	<th class="client">Client</th>
    	<th class="time">Time</th>
    </tr>
    
  	<xsl:apply-templates select="worker">
  		<xsl:sort select="number(@requestProcessingTime)" order="ascending"/>
  	</xsl:apply-templates>

   </table>
  </xsl:template>

  <xsl:template match="worker[@stage='S']">
	<tr>
		<td class="url">
			<strong><xsl:value-of select="@method"/></strong>
			<span class="uri"><xsl:value-of select="@currentUri"/></span>
			<xsl:if test="@currentQueryString != '?'">
				<span class="query"><xsl:value-of select="@currentQueryString"/></span>
			</xsl:if>
		</td>
		<td class="client">
			<xsl:choose>
			<xsl:when test="@remoteAddr = '127.0.0.1'"><span>(local)</span></xsl:when>
			<xsl:otherwise><xsl:value-of select="@remoteAddr"/></xsl:otherwise>
			</xsl:choose>
		</td>
		<xsl:variable name="time" select="number(@requestProcessingTime)"/>
		<td>
			<xsl:attribute name="class">
				time
				<xsl:choose>
					<xsl:when test="$time &gt; 5000 and $time &lt; 10000">warn</xsl:when>
					<xsl:when test="$time &gt; 10000">error</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="@requestProcessingTime"/><abbr>ms</abbr>
		</td>
	</tr>
  </xsl:template>

</xsl:stylesheet>
