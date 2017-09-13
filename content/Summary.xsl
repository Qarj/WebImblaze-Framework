<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
  <head>
    <title>Overall Summary</title>
    <style type="text/css">
    @import url(/content/Summary.css);
    </style>
	<script type="text/javascript" src="/scripts/jquery-2.2.3.min.js"></script>
	<script type="text/javascript" src="/scripts/filter.js"></script>
  </head>
  <body>
    <div id="heading">
      <h1>
        WebInject Results
        (
        <A href="http://localhost/DEV/Summary.xml"> DEV </A>
        /
        <A href="http://localhost/PAT/Summary.xml"> PAT </A>
        /
        <A href="http://localhost/PROD/Summary.xml"> PROD </A>
        )
      </h1>
      <br />
      <h2>
         <xsl:value-of select="summary/channel/title"/>
         &#160;&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;&#160;  &#160;&#160;&#160;&#160;&#160; &#160;&#160;&#160;&#160;&#160;
         <a href="{summary/channel/link}">(Click for previous day's results)</a>
      </h2>
    </div>

    <div id="filter">
        <button class="active btn" data-filter="result">Show All</button>
        <button class="btn" data-filter="pass">Passed</button>
        <button class="btn" data-filter="pend">Pending</button>
        <button class="btn" data-filter="fail">Failed</button>
        <button class="btn" data-filter="abort">Execution Aborted</button>

        <form id="live-search" action="" class="inputbox" onsubmit="return submitFilter()">
            <fieldset>
                <input type="text" class="text-input" id="live-filter" value="" />
            </fieldset>
        </form>

    </div>


    <div class="spacer"></div>
    
    <div id="results">
    <ul>
      <xsl:for-each select="summary/channel/item">
      <div class="article">
        <xsl:if test="contains(title, 'PASS')">
           <li class="row"><a class="result pass" href="{link}" rel="bookmark"><xsl:value-of select="title"/></a></li>
        </xsl:if>        
        <xsl:if test="contains(title, 'PEND')">
           <li class="row"><a class="result pend" href="{link}" rel="bookmark"><xsl:value-of select="title"/></a></li>
        </xsl:if>        
        <xsl:if test="contains(title, 'CORRUPT')">
           <li class="row"><a class="result corrupt" href="{link}" rel="bookmark"><xsl:value-of select="title"/></a></li>
        </xsl:if>        
        <xsl:if test="contains(title, 'FAILED')">
            <xsl:choose>
                <xsl:when test="contains(title, 'EXECUTION ABORTION')">
                    <li class="row"><a class="result abort" href="{link}" rel="bookmark"><xsl:value-of select="title"/></a></li>
                </xsl:when>        
                <xsl:otherwise>        
                    <li class="row"><a class="result fail" href="{link}" rel="bookmark"><xsl:value-of select="title"/></a></li>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:if>        
      </div>
      </xsl:for-each>
      </ul>
    </div>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
