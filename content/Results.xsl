<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/">
  <html>
    <head>
        <title>Batch Summary</title>
        <style type="text/css">
        @import url(/content/Results.css);
        </style>
    </head>
    <body>

        <div id="heading">
            <xsl:variable name="runof"><xsl:value-of select="substring-before(substring-after(results/testcases/@file,'\testcases\'),'.xml')"/></xsl:variable>
            <h1>Test Results [<xsl:value-of select="results/test-summary/test-file-name"/>]</h1>
            <br />
            <h2>
                <xsl:variable name="environment_link">/<xsl:value-of select="results/wif/environment"/>/<xsl:value-of select="results/wif/yyyy"/>/<xsl:value-of select="results/wif/mm"/>/<xsl:value-of select="results/wif/dd"/>/All_Batches/Summary.xml</xsl:variable>
                <xsl:variable name="batch_link">/<xsl:value-of select="results/wif/environment"/>/<xsl:value-of select="results/wif/yyyy"/>/<xsl:value-of select="results/wif/mm"/>/<xsl:value-of select="results/wif/dd"/>/All_Batches/<xsl:value-of select="results/wif/batch"/>.xml</xsl:variable>
                <a href="{$environment_link}"> Summary </a> -&gt; <a href="{$batch_link}"> Batch Summary </a> -&gt; Run Results
            </h2>
        </div>

    <xsl:for-each select="results/test-summary">
      <xsl:text>Started </xsl:text>
      <xsl:value-of select="start-time"/>
      <xsl:text>. Max response time </xsl:text>
      <xsl:value-of select="max-response-time"/>
      <xsl:text> s. Ran for </xsl:text>
      <xsl:value-of select="total-run-time"/>
      <xsl:text> s.</xsl:text>
    </xsl:for-each>
    <xsl:text> Sum of response times </xsl:text>
    <xsl:value-of  select="sum(//responsetime)" /> 
    <xsl:text> s. </xsl:text>
    <br/><A href="http.txt" target="_blank">Full HTTP log (with headers)</A> <xsl:text> </xsl:text> <A href="results.html">Results.html</A>
    <xsl:choose>
      <xsl:when test="sum(//verificationtime)>0">
        <xsl:text> </xsl:text> <A href="selenium_log.txt">selenium_log</A>
        <xsl:text> </xsl:text> <A href="URLs.txt">URLs</A>
        <xsl:text> </xsl:text> <A href="TransferSize.txt">TransferSize (small tests only) </A>
      </xsl:when>
    </xsl:choose>
    <table border="1" style="font-family:Arial;font-size:80%">
    <tr bgcolor="#CCCCCC">
      <th align="left">id</th>
      <th align="left">Test Step</th>
      <th align="left">Result</th>
      <th align="left">Time</th>
      <xsl:choose>
        <xsl:when test="sum(//baselinematch)>0">
          <th align="left">Image Match</th>
        </xsl:when>
      </xsl:choose>


    </tr>
    <xsl:for-each select="results/testcases/testcase">
    <!--	Set a variable to hold the href link -->
    <xsl:variable name="href"><xsl:value-of select="@id"/></xsl:variable>

   	  <xsl:choose>
        <xsl:when test="section">
            <tr>
                <td bgcolor="#E7CECE"></td>
                <td bgcolor="#E7CECE" align="center"> <b> <xsl:value-of select="section"/> </b> </td>
                <td bgcolor="#E7CECE"></td>
                <td bgcolor="#E7CECE"></td>
                <xsl:choose>
                    <xsl:when test="sum(//baselinematch)>0">
                        <td bgcolor="#E7CECE"></td>
                    </xsl:when>
                </xsl:choose>
            </tr>
        </xsl:when>
      </xsl:choose>

    <tr>
      <td><a href="{$environment_link}.html" target="_blank"><xsl:value-of select="@id"/></a></td>
      <td>
        
        <!-- Make any text that appears between square brackets brown bold -->
        <xsl:variable name="desc1inSB" select="substring-after(substring-before(description1, ']'), '[')"/>
        <xsl:variable name="desc1afterSB" select="substring-after(description1, ']')"/>
        <xsl:variable name="desc1beforeSB" select="substring-before(description1, '[')"/>
        <xsl:variable name="desc1" select="description1"/>

        <!-- If description1 starts with "Info " then make description1 bold green  -->
        <xsl:choose>
            <xsl:when test="not($desc1inSB)"> <!-- parameter has not been supplied -->
                <xsl:choose>
                    <xsl:when test="starts-with($desc1, 'Info ')">
                        <b><font color="green">
                            <xsl:value-of select="description1"/>
                        </font></b>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="description1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise> <!--parameter has been supplied -->
                <xsl:value-of select="$desc1beforeSB"/><font color="brown"><b>[<xsl:value-of select="$desc1inSB"/>]</b></font><xsl:value-of select="$desc1afterSB"/>
            </xsl:otherwise>
        </xsl:choose>

        <small><xsl:text> </xsl:text><xsl:value-of select="description2"/></small></td>
        <xsl:variable name="message" select="result-message" />
     	<xsl:choose>
        <xsl:when test="result-message='TEST CASE FAILED'">
          <td bgcolor="#FA6565"> <xsl:text>FAIL</xsl:text> </td>
        </xsl:when>
        <xsl:when test="result-message='TEST CASE PASSED'">
          <td bgcolor="#CCFF99"> <xsl:text>PASS</xsl:text> </td>
        </xsl:when>
        <xsl:when test="contains($message,'RETRYING...')">
          <td bgcolor="#CCFF99"><xsl:value-of select="result-message"/></td>
        </xsl:when>
        <xsl:when test="contains($message,'RETRYING FROM STEP')">
          <td bgcolor="#FFCC00"><xsl:value-of select="result-message"/></td>
        </xsl:when>
        <xsl:otherwise>
          <td bgcolor="#FA6565"><xsl:value-of select="result-message"/></td>
        </xsl:otherwise>
      </xsl:choose>
     	<xsl:choose>
        <xsl:when test="responsetime>90">
          <td bgcolor="#FF4500"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:when test="responsetime>30">
          <td bgcolor="#FFA500"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:when test="responsetime>5">
          <td bgcolor="#B8CCE4"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:otherwise>
          <td bgcolor="#FFFFFF"><xsl:value-of select="responsetime"/></td>
        </xsl:otherwise>
      </xsl:choose>
 
      <xsl:choose>
        <xsl:when test="baselinematch>70">
          <td bgcolor="#FFFFFF"> <xsl:value-of select="baselinematch"/> <xsl:text>%</xsl:text> </td>
        </xsl:when>
        <xsl:when test="baselinematch>50">
          <td bgcolor="#CCFF00"> <xsl:value-of select="baselinematch"/> <xsl:text>%</xsl:text> </td>
        </xsl:when>
        <xsl:when test="baselinematch>0.01">
          <td bgcolor="#FF6600"> <xsl:value-of select="baselinematch"/> <xsl:text>%</xsl:text> </td>
        </xsl:when>
        <xsl:when test="sum(//baselinematch)>0">
          <td bgcolor="#FFFFFF">                                        <xsl:text> </xsl:text> </td>
        </xsl:when>
      </xsl:choose>

                   <xsl:choose>
                       <xsl:when test="searchimage-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="searchimage1-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage1-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage1-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="searchimage2-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage2-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage2-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="searchimage3-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage3-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage3-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="searchimage4-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage4-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage4-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="searchimage5-success='false'">
                           <td bgcolor="#FFC0FF">
                      	   <xsl:choose>
                               <xsl:when test="searchimage5-name">
                                   <xsl:text>Not Found: </xsl:text>
                                   <xsl:value-of select="searchimage5-name"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>

 
                   <xsl:choose>
                       <xsl:when test="verifyresponsecode-success='false'">
                           <td bgcolor="#FF6633">
                               <xsl:value-of select="verifyresponsecode-message"/>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="image-success='false'">
                           <td bgcolor="#FFC000">
                      	   <xsl:choose>
                               <xsl:when test="image-message">
                                   <xsl:value-of select="image-message"/>
                               </xsl:when>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="verifynegative-success='false'">
                           <td bgcolor="#FFC000">
                      	   <xsl:choose>
                               <xsl:when test="verifynegative-message">
                                   <xsl:value-of select="verifynegative-message"/>
                               </xsl:when>
                               <xsl:otherwise>
                                   <xsl:text>FOUND: </xsl:text>
                                   <xsl:value-of select="verifynegative"/>
                               </xsl:otherwise>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                   <xsl:choose>
                       <xsl:when test="verifynegative1-success='false'">
                           <td bgcolor="#FFC000">
                      	   <xsl:choose>
                               <xsl:when test="verifynegative1-message">
                                   <xsl:value-of select="verifynegative1-message"/>
                               </xsl:when>
                               <xsl:otherwise>
                                   <xsl:text>FOUND: </xsl:text>
                                   <xsl:value-of select="verifynegative1"/>
                               </xsl:otherwise>
                           </xsl:choose>
                           </td>
                       </xsl:when>
                   </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative2-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative2-message">
                                <xsl:value-of select="verifynegative2-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative2"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative3-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative3-message">
                                <xsl:value-of select="verifynegative3-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative3"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative4-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative4-message">
                                <xsl:value-of select="verifynegative4-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative4"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative5-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative5-message">
                                <xsl:value-of select="verifynegative5-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative5"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative6-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative6-message">
                                <xsl:value-of select="verifynegative6-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative6"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative7-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative7-message">
                                <xsl:value-of select="verifynegative7-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative7"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative8-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative8-message">
                                <xsl:value-of select="verifynegative8-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative8"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative9-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative9-message">
                                <xsl:value-of select="verifynegative9-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative9"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative10-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative10-message">
                                <xsl:value-of select="verifynegative10-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative10"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative11-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative11-message">
                                <xsl:value-of select="verifynegative11-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative11"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative12-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative12-message">
                                <xsl:value-of select="verifynegative12-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative12"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative13-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative13-message">
                                <xsl:value-of select="verifynegative13-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative13"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative14-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative14-message">
                                <xsl:value-of select="verifynegative14-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative14"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative15-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative15-message">
                                <xsl:value-of select="verifynegative15-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative15"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative16-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative16-message">
                                <xsl:value-of select="verifynegative16-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative16"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative17-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative17-message">
                                <xsl:value-of select="verifynegative17-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative17"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative18-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative18-message">
                                <xsl:value-of select="verifynegative18-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative18"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                	<xsl:choose>
                     <xsl:when test="verifynegative19-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative19-message">
                                <xsl:value-of select="verifynegative19-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative19"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative20-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative20-message">
                                <xsl:value-of select="verifynegative20-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative20"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative21-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative21-message">
                                <xsl:value-of select="verifynegative21-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative21"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative22-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative22-message">
                                <xsl:value-of select="verifynegative22-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative22"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative23-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative23-message">
                                <xsl:value-of select="verifynegative23-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative23"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative24-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative24-message">
                                <xsl:value-of select="verifynegative24-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative24"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifynegative25-success='false'">
                      <td bgcolor="#FFC000">
                      	 <xsl:choose>
                            <xsl:when test="verifynegative25-message">
                                <xsl:value-of select="verifynegative25-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>FOUND: </xsl:text>
                                <xsl:value-of select="verifynegative25"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive-message">
                                <xsl:value-of select="verifypositive-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive1-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive1-message">
                                <xsl:value-of select="verifypositive1-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive1"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive2-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive2-message">
                                <xsl:value-of select="verifypositive2-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive2"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive3-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive3-message">
                                <xsl:value-of select="verifypositive3-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive3"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive4-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive4-message">
                                <xsl:value-of select="verifypositive4-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive4"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive5-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive5-message">
                                <xsl:value-of select="verifypositive5-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive5"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive6-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive6-message">
                                <xsl:value-of select="verifypositive6-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive6"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive7-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive7-message">
                                <xsl:value-of select="verifypositive7-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive7"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive8-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive8-message">
                                <xsl:value-of select="verifypositive8-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive8"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive9-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive9-message">
                                <xsl:value-of select="verifypositive9-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive9"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive10-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive10-message">
                                <xsl:value-of select="verifypositive10-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive10"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive11-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive11-message">
                                <xsl:value-of select="verifypositive11-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive11"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive12-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive12-message">
                                <xsl:value-of select="verifypositive12-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive12"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive13-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive13-message">
                                <xsl:value-of select="verifypositive13-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive13"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive14-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive14-message">
                                <xsl:value-of select="verifypositive14-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive14"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="verifypositive15-success='false'">
                      <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive15-message">
                                <xsl:value-of select="verifypositive15-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive15"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive16-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive16-message">
                                <xsl:value-of select="verifypositive16-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive16"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive17-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive17-message">
                                <xsl:value-of select="verifypositive17-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive17"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive18-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive18-message">
                                <xsl:value-of select="verifypositive18-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive18"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive19-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive19-message">
                                <xsl:value-of select="verifypositive19-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive19"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive20-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive20-message">
                                <xsl:value-of select="verifypositive20-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive20"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive21-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive21-message">
                                <xsl:value-of select="verifypositive21-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive21"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive22-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive22-message">
                                <xsl:value-of select="verifypositive22-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive22"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive23-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive23-message">
                                <xsl:value-of select="verifypositive23-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive23"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive24-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive24-message">
                                <xsl:value-of select="verifypositive24-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive24"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifypositive25-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifypositive25-message">
                                <xsl:value-of select="verifypositive25-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="verifypositive25"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="autoassertion1-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="autoassertion1-message">
                                <xsl:value-of select="autoassertion1-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="autoassertion1"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="autoassertion2-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="autoassertion2-message">
                                <xsl:value-of select="autoassertion2-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="autoassertion2"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="autoassertion3-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="autoassertion3-message">
                                <xsl:value-of select="autoassertion3-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="autoassertion3"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="autoassertion4-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="autoassertion4-message">
                                <xsl:value-of select="autoassertion4-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="autoassertion4"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="smartassertion1-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="smartassertion1-message">
                                <xsl:value-of select="smartassertion1-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="smartassertion1"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="smartassertion2-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="smartassertion2-message">
                                <xsl:value-of select="smartassertion2-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="smartassertion2"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="smartassertion3-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="smartassertion3-message">
                                <xsl:value-of select="smartassertion3-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="smartassertion3"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="smartassertion4-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="smartassertion4-message">
                                <xsl:value-of select="smartassertion4-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>EXPECTED: </xsl:text>
                                <xsl:value-of select="smartassertion4"/>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="assertcount-success='false'">
                       <td bgcolor="#FF82F8">
                      	 <xsl:choose>
                            <xsl:when test="assertcount-message">
                                <xsl:value-of select="assertcount-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>assertcount failed</xsl:text>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                      <xsl:when test="verifyresponsetime-success='false'">
                       <td bgcolor="#CC99FF">
                      	 <xsl:choose>
                            <xsl:when test="verifyresponsetime-message">
                                <xsl:value-of select="verifyresponsetime-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>response time verification failed</xsl:text>
                            </xsl:otherwise>
                         </xsl:choose>
                       </td></xsl:when>
                  </xsl:choose>

                	<xsl:choose>
                     <xsl:when test="assertionskips='true'">
                      <td bgcolor="#66D4EF">
                      	 <xsl:choose>
                            <xsl:when test="assertionskips-message">
                                <xsl:value-of select="assertionskips-message"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Some assertions were skipped </xsl:text>
                            </xsl:otherwise>
                         </xsl:choose>
                      </td></xsl:when>
                  </xsl:choose>

    </tr>
    </xsl:for-each>
    </table>
    <br/>
  </body>
  </html>
</xsl:template></xsl:stylesheet>