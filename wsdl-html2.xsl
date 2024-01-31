<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version='1.0' 
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
  xmlns:s="http://www.w3.org/2001/XMLSchema"
  xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" 
  xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/"
  exclude-result-prefixes="wsdl s soap soap12" >

<xsl:output method="html" encoding="UTF-8" indent="no" omit-xml-declaration="no"/>

<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<style>
	.wsdlinfo-operation-name {
		border-top: 1px solid gray;
		font-weight: bold;
		text-align:  left;
	}
	
	.wsdlinfo-operation-doc {
		border-top: 1px solid gray;
		font-style:italic;
	}
	
	
	.wsdlinfo-operation-key {
		text-align:  right;
		font-size:   smaller;
		color:       maroon;
		vertical-align: top;
	}
	
	.wsdlinfo-operation-message {
		text-align:  left;
		font-size:   smaller;
	}
	
	.wsdlinfo-message-type {
		color:       #0000AA;
		cursor:      pointer;
	}
	
	.wsdlinfo-simple-type {
		color:       #0000FF;
	}
	.wsdlinfo-element-doc {
		color:#777777;
		font-style:italic;
		margin-left:25px;
	}
	
	.wsdlinfo-head {
		font-weight: bold;
		font-size:   larger;
	}
	
	.wsdlinfo-doc {
		font-style:italic;
	}
	
	.wsdlinfo ul{
		margin-top:       0;
		margin-bottom:    0;
	}
	
	.wsdlinfo{
		width:    900px;
	}
	
	.wsdlinfo td{
		padding-left:      5;
		padding-right:     5;
	}
	
	.wsdlinfo-type-box {
		background-color:#EEEEEE;
		border:1px solid gray;
		margin-top:       4;
	}
	
	
	</style>
	<script type="text/javascript">
	function wsdlinfoToggle(id) {
		var el = document.getElementById(id);
		if ( el.style.display != 'none' ) {
			el.style.display = 'none';
		} else {
			el.style.display = '';
		}
		return false;
	}
	</script>
	<script type="text/javascript">
		<xsl:text disable-output-escaping="yes"><![CDATA[
	function applyWiki2Html() { 
		var domNode = document;
		var tagName = '*';
		var searchClass = ' wsdlinfo-operation-doc ';
		var tags = domNode.getElementsByTagName(tagName);
		var i=0,busy=false;
		var processor = setInterval( function() {
			if(!busy) {
				busy = true;
				
				if( i < tags.length ) {
					var y=0
					while(i < tags.length && y<300) {
						var test = " " + tags[i].className + " ";
						if (searchClass.indexOf(test) != -1){
							tags[i].innerHTML = wiki2html(tags[i].innerHTML);
						}
						i++;
						y++;
					}
				}else{
					clearInterval(processor);
				}
				
				busy = false;
			}
		},100);
	}


	// the regex beast...
	function wiki2html(s) {
		
		// lists need to be done using a function to allow for recusive calls
		function list(str) {
			return str.replace(/(?:(?:(?:^|\n)[\*#].*)+)/g, function (m) {  // (?=[\*#])
				var type = m.match(/(^|\n)#/) ? 'OL' : 'UL';
				// strip first layer of list
				m = m.replace(/(^|\n)[\*#][ ]{0,1}/g, "$1");
				m = list(m);
				return '<' + type + '><li>' + m.replace(/^\n/, '').split(/\n/).join('</li><li>') + '</li></' + type + '>';
			});
		}
		
		return list(s
			
			/* BLOCK ELEMENTS */
			
			.replace(/[\[](http.*)[!\]]/g, function (m, l) { // external link
				var p = l.replace(/[\[\]]/g, '').split(/[ |]/);
				var link = p.shift();
				return '<a href="' + link + '">' + (p.length ? p.join(' ') : link) + '</a>';
			})
			.replace(/[\[](.*|\s*http.*)[!\]]/g, function (m, l) { // external link
				var p = l.replace(/[\[\]]/g, '').split(/[|]/);
				var text = p.shift();
				var link = p.shift();
				return '<a href="' + link + '">' + text + '</a>';
			})
		); 
	}
		
		]]></xsl:text>
	</script>
	
	<table class="wsdlinfo" border="0" cellspacing="0">
		<tr><td class="wsdlinfo-head" colspan="2">Service: <xsl:value-of select="wsdl:definitions/wsdl:service/@name"/></td></tr>
		<tr><td class="wsdlinfo-doc" colspan="2"><xsl:value-of select="wsdl:definitions/wsdl:documentation"/></td></tr>
		<xsl:for-each select="/wsdl:definitions/wsdl:portType/wsdl:operation">
           <xsl:sort select="@name"/>
			<xsl:variable name="inputMessageName" select="substring-after(wsdl:input/@message, ':')"/>
			<xsl:variable name="outputMessageName" select="substring-after(wsdl:output/@message, ':')"/>
			<tr class="wsdlinfo-operation-row">
				<td class="wsdlinfo-operation-name">
					<a name="Operation-{@name}" href="#Operation-{@name}"><xsl:value-of select="@name"/></a>
				</td>
				<td class="wsdlinfo-operation-doc" width="100%"><xsl:value-of select="wsdl:documentation"/></td>
			</tr>

			<xsl:call-template name="show-wsdl-message">
				<xsl:with-param name="msg-type" select="'input'"/>
				<xsl:with-param name="msg-name" select="substring-after(wsdl:input/@message, ':')"/>
			</xsl:call-template>

			<xsl:call-template name="show-wsdl-message">
				<xsl:with-param name="msg-type" select="'output'"/>
				<xsl:with-param name="msg-name" select="substring-after(wsdl:output/@message, ':')"/>
			</xsl:call-template>
		</xsl:for-each>
	</table>
	<script type="text/javascript">
		applyWiki2Html();
	</script>
</xsl:template>
  
  
<xsl:template name="show-wsdl-message">
	<xsl:param name="msg-type"/>
	<xsl:param name="msg-name"/>
	<tr>
		<td class="wsdlinfo-operation-key"><xsl:value-of select="$msg-type"/>:</td>
		<td class="wsdlinfo-operation-message">
			<span class="wsdlinfo-message-type" onclick="wsdlinfoToggle('wsdlinfo-msg-{$msg-name}')"><xsl:value-of select="$msg-name"/></span>
			<div id="wsdlinfo-msg-{$msg-name}" style="display: none;" class="wsdlinfo-type-box">
				<ul class="wsdlinfo-type">
					<xsl:for-each select="/wsdl:definitions/wsdl:message[@name=$msg-name]/wsdl:part">
						<xsl:call-template name="show-xsd-type">
							<xsl:with-param name="xsd-name" select="substring-after(@element,':')"/>
							<xsl:with-param name="xsd-type" select="substring-after(@element,':')"/>
						</xsl:call-template>
					</xsl:for-each>
				</ul>
			</div>
		</td>
	</tr>
</xsl:template>

<xsl:template name="show-xsd-type">
	<xsl:param name="xsd-name"/>
	<xsl:param name="xsd-type"/>
	<xsl:param name="recursion.count">1</xsl:param>
	<xsl:param name="xsd-ref"/>
	<xsl:param name="xsd-doc"/>
	<xsl:param name="xsd-min"/>
	<xsl:param name="xsd-max"/>
	

	
    <!--xsl:variable name="xsd-type" select="substring-after(/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-name]/@type,':')" /-->
    <!--xsl:variable name="xsd-type-lwr" select="translate($xsd-type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" /-->
    
	<xsl:choose>
		<!--limit nest level-->
		<xsl:when test="$recursion.count  > 16"/>

		<xsl:when test="$xsd-ref">
			<!--if it's a reference lookup for definition-->
			<!--TODO:probably have to move all lookups here...-->

			<xsl:choose>
		
				<!--check comlextype: complexType -->
				<xsl:when test="count(/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-ref]) > 0">
					<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-ref]">
						<ul class="wsdlinfo-type">
						<xsl:choose>
							<xsl:when test="@minOccurs or @maxOccurs">
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="xsd-name" select="@name"/>
									<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
									<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
									<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
									<xsl:with-param name="xsd-min" select="@minOccurs"/>
									<xsl:with-param name="xsd-max" select="@maxOccurs"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="xsd-name" select="@name"/>
									<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
									<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
									<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
									<xsl:with-param name="xsd-min" select="$xsd-min"/>
									<xsl:with-param name="xsd-max" select="$xsd-max"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
						</ul>
					</xsl:for-each>
				</xsl:when>
				<!--lookup for complex ref type-->
				<xsl:when test="count(/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-ref]) > 0">
					<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-ref]/*/s:element">
						<xsl:choose>
							<xsl:when test="@ref">
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="xsd-ref" select="substring-after(@ref,':')"/>
									<xsl:with-param name="recursion.count" select="$recursion.count+1"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<ul class="wsdlinfo-type">
									<xsl:call-template name="show-xsd-type">
										<xsl:with-param name="xsd-name" select="@name"/>
										<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
										<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
										<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
										<xsl:with-param name="xsd-min" select="@minOccurs"/>
										<xsl:with-param name="xsd-max" select="@maxOccurs"/>
									</xsl:call-template>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>


		</xsl:when>
		<xsl:when test="$xsd-name and $xsd-type">
			<!--name and type must be defined, so print it out-->
			<li>
				<xsl:value-of select="$xsd-name"/>
				<xsl:choose>
					<xsl:when test="$xsd-min='0' and ($xsd-max='1' or not($xsd-max))"> (?) </xsl:when>
					<xsl:when test="$xsd-min='0' and $xsd-max='unbounded'"> (*) </xsl:when>
					<xsl:when test="($xsd-max='1' or not($xsd-max)) and $xsd-max='unbounded'"> (+) </xsl:when>
				</xsl:choose>
				<xsl:text> - </xsl:text>
				<span class="wsdlinfo-simple-type"><xsl:value-of select="$xsd-type"/></span>
				<xsl:if test="$xsd-doc">
					<div class="wsdlinfo-element-doc"><xsl:value-of select="$xsd-doc"/></div>
				</xsl:if>
			</li>
			
			<xsl:choose>
		
				<!--check complextype as extended simple: complexType/simpleContent/extension/@base-->
				<xsl:when test="count(/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-type]/s:simpleContent/s:extension)=1">
					<!--ul class="wsdlinfo-element-doc"><xsl:text>simpleContent/extension/@base</xsl:text></ul-->
					<!--let's display value as separate item...-->
					<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-type]/s:simpleContent/s:extension">
						<ul class="wsdlinfo-type">
							<xsl:call-template name="show-xsd-type">
								<xsl:with-param name="xsd-name" select="'[value]'"/>
								<xsl:with-param name="xsd-type" select="substring-after(@base,':')"/>
								<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
								<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
								<!--xsl:with-param name="xsd-min" select="number(@use='required')"/-->
								<!--xsl:with-param name="xsd-max" select="@maxOccurs"/-->
							</xsl:call-template>
						</ul>
					</xsl:for-each>
					<!--attributes-->
					<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-type]/s:simpleContent/s:extension/s:attribute">
						<xsl:choose>
							<xsl:when test="@ref">
								<!--i think we don't have @ref for attributes-->
							</xsl:when>
							<xsl:otherwise>
								<ul class="wsdlinfo-type">
									<xsl:call-template name="show-xsd-type">
										<xsl:with-param name="xsd-name" select="concat('@',@name)"/>
										<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
										<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
										<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
										<xsl:with-param name="xsd-min" select="number(@use='required')"/>
										<!--xsl:with-param name="xsd-max" select="@maxOccurs"/-->
									</xsl:call-template>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<!--no elements ??? -->
				</xsl:when>

				<!--check comlextype: complexType -->
				<xsl:when test="count(/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-type]) > 0">
					<!--it's a complex type-->
					<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:complexType[@name=$xsd-type]/*/s:element">
						<xsl:choose>
							<xsl:when test="@ref">
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="xsd-ref" select="substring-after(@ref,':')"/>
									<xsl:with-param name="recursion.count" select="$recursion.count"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<ul class="wsdlinfo-type">
									<xsl:call-template name="show-xsd-type">
										<xsl:with-param name="xsd-name" select="@name"/>
										<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
										<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
										<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
										<xsl:with-param name="xsd-min" select="@minOccurs"/>
										<xsl:with-param name="xsd-max" select="@maxOccurs"/>
									</xsl:call-template>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:when>
		
				
  
				<xsl:when test="count(/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-name]) > 0">
					<xsl:choose>
						<xsl:when test="/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-name]/@type">
							<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-type and @type]">
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="xsd-ref" select="substring-after(@type,':')"/>
									<xsl:with-param name="recursion.count" select="$recursion.count"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:when test="/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-name]/*">
							<!--there are recursive elements. let's go through them-->
							<ul class="wsdlinfo-element-doc"><xsl:value-of select="./s:annotation/s:documentation"/></ul>
							<xsl:for-each select="/wsdl:definitions/wsdl:types/s:schema/s:element[@name=$xsd-type]">
								<xsl:call-template name="show-xsd-type">
									<xsl:with-param name="recursion.count" select="$recursion.count"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
		
		
		        <xsl:otherwise>
		        </xsl:otherwise>
		
			</xsl:choose>
		</xsl:when>

		<!-- simpletype enumeration -->
		<xsl:when test="$xsd-name and count(./s:simpleType/s:restriction/s:enumeration) > 0">
			<!--we have a simple enumeration type. let's display it-->
			<li>
				<xsl:value-of select="$xsd-name"/>
				<xsl:text> - </xsl:text>
				<span class="wsdlinfo-simple-type">
					<xsl:text>enum[ </xsl:text>
					<xsl:for-each select="./s:simpleType/s:restriction/s:enumeration">
						<xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
						<xsl:value-of select="@value"/>
					</xsl:for-each>
					<xsl:text> ]</xsl:text>
					<xsl:value-of select="$xsd-type"/>
				</span>
				<xsl:if test="$xsd-doc">
					<div class="wsdlinfo-element-doc"><xsl:value-of select="$xsd-doc"/></div>
				</xsl:if>
			</li>
		</xsl:when>

		<!-- simpletype restriction in current context -->
		<xsl:when test="$xsd-name and count(./s:simpleType/s:restriction/s:pattern) > 0">
			<!--we have a simple type with restrictions -->
			<li>
				<xsl:value-of select="$xsd-name"/>
				<xsl:text> - </xsl:text>
				<span class="wsdlinfo-simple-type">
					<xsl:value-of select="substring-after(s:simpleType/s:restriction/@base,':')"/>
					<xsl:text>[ </xsl:text>
					<xsl:text>pattern:</xsl:text>
					<xsl:value-of select="s:simpleType/s:restriction/s:pattern/@value"/>
					<xsl:text> ]</xsl:text>
					<xsl:value-of select="$xsd-type"/>
				</span>
				<xsl:if test="$xsd-doc">
					<div class="wsdlinfo-element-doc"><xsl:value-of select="$xsd-doc"/></div>
				</xsl:if>
			</li>
		</xsl:when>

		<!-- unnamed complex type in current context -->
		<xsl:when test="count(./s:complexType[not(@name)]) > 0"><!--unnamed/inline complex type -->
			<!--attributes-->
			<ul class="wsdlinfo-type">
			<li>
				<xsl:value-of select="@name"/>
				<xsl:text> - </xsl:text>
				<span class="wsdlinfo-simple-type"><xsl:value-of select="@name"/></span>
				<xsl:if test="$xsd-doc">
					<div class="wsdlinfo-element-doc"><xsl:value-of select="./s:annotation/s:documentation"/></div>
				</xsl:if>
			</li>
			<xsl:for-each select="./s:complexType[not(@name)]/s:attribute">
				<xsl:choose>
					<xsl:when test="@ref">
						<!--i think we don't have @ref for attributes-->
					</xsl:when>
					<xsl:otherwise>
						<ul class="wsdlinfo-type">
							<xsl:call-template name="show-xsd-type">
								<xsl:with-param name="xsd-name" select="concat('@',@name)"/>
								<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
								<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
								<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
								<xsl:with-param name="xsd-min" select="@minOccurs"/>
								<xsl:with-param name="xsd-max" select="@maxOccurs"/>
							</xsl:call-template>
						</ul>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<!-- elements  -->
			<xsl:for-each select="./s:complexType[not(@name)]/*/s:element">
				<xsl:choose>
					<xsl:when test="@ref">
						<xsl:call-template name="show-xsd-type">
							<xsl:with-param name="xsd-ref" select="substring-after(@ref,':')"/>
							<xsl:with-param name="recursion.count" select="$recursion.count"/>
							<xsl:with-param name="xsd-min" select="@minOccurs"/>
							<xsl:with-param name="xsd-max" select="@maxOccurs"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<ul class="wsdlinfo-type">
							<xsl:call-template name="show-xsd-type">
								<xsl:with-param name="xsd-name" select="@name"/>
								<xsl:with-param name="xsd-type" select="substring-after(@type,':')"/>
								<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
								<xsl:with-param name="xsd-doc" select="./s:annotation/s:documentation"/>
								<xsl:with-param name="xsd-min" select="@minOccurs"/>
								<xsl:with-param name="xsd-max" select="@maxOccurs"/>
							</xsl:call-template>
						</ul>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			</ul>
		</xsl:when>


		<xsl:when test="$xsd-name">
			<xsl:call-template name="show-xsd-type">
				<xsl:with-param name="xsd-name" select="$xsd-name"/>
				<xsl:with-param name="xsd-type" select="$xsd-name"/>
				<xsl:with-param name="recursion.count" select="$recursion.count + 1"/>
			</xsl:call-template>
		</xsl:when>

		<xsl:otherwise>
			<xsl:message>???</xsl:message>
		</xsl:otherwise>
		
	</xsl:choose>
	
    
</xsl:template>


  
</xsl:stylesheet>


<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="wsdl-html-test.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
		          commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="wsdl-html-test.xml" srcSchemaRoot="wsdl:definitions" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="table/xsl:for-each" x="585" y="78"/>
				<block path="table/xsl:for-each/xsl:call-template" x="535" y="108"/>
				<block path="table/xsl:for-each/xsl:call-template/substring-after[1]" x="489" y="130"/>
				<block path="table/xsl:for-each/xsl:call-template[1]" x="495" y="108"/>
				<block path="table/xsl:for-each/xsl:call-template[1]/substring-after[1]" x="449" y="130"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->