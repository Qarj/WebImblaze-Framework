<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/">
  <html>
    <head>
        <title>Batch Summary</title>
        <style type="text/css">
        @import url(/content/Results.css);
        </style>
    	<script type="text/javascript" src="/scripts/jquery-2.2.3.min.js"></script>
    	<script type="text/javascript">
<![CDATA[
    $(document).ready(function() {

        $("#live-filter").keyup(function(){
     
            // Retrieve the input field text
            var filter = $(this).val();
     
            // Loop through the test step results
            $("tr.step_result").each(function(){
     
                // If the list item does not contain the text phrase fade it out
                if ($(this).text().search(new RegExp(filter, "i")) < 0) {
                    $(this).fadeOut();
     
                // Show the list item if the phrase matches
                } else {
                    $(this).show();
                }
            });
     
        });


	});

]]>
    	</script>
    </head>
    <body>

        <div id="heading">
            <h1 class="alignleft">Test Results [<xsl:value-of select="results/test-summary/test-file-name"/> - <xsl:value-of select="results/test-summary/total-run-time"/><xsl:text>s</xsl:text>]</h1>
            <h3 class="alignright">
              <xsl:value-of select="results/test-summary/start-time"/>
            </h3>
            <div style="clear: both;"></div>
            <br />
            <h2>
                <xsl:variable name="environment_link">/<xsl:value-of select="results/wif/environment"/>/<xsl:value-of select="results/wif/yyyy"/>/<xsl:value-of select="results/wif/mm"/>/<xsl:value-of select="results/wif/dd"/>/All_Batches/Summary.xml</xsl:variable>
                <xsl:variable name="batch_link">/<xsl:value-of select="results/wif/environment"/>/<xsl:value-of select="results/wif/yyyy"/>/<xsl:value-of select="results/wif/mm"/>/<xsl:value-of select="results/wif/dd"/>/All_Batches/<xsl:value-of select="results/wif/batch"/>.xml</xsl:variable>
                <a href="{$environment_link}"> Summary </a> -&gt; <a href="{$batch_link}"> Batch Summary </a> -&gt; Run Results
            </h2>
        </div>

        <div id="filter">
            <A class="btn" href="http.txt" target="_blank">Full HTTP Log</A>
            <A class="btn" href="Results.html" target="_blank">HTML Results</A>
    
            <form id="live-search" action="" class="inputbox" method="post">
                <fieldset>
                    <input type="text" class="text-input" id="live-filter" value="" />
                </fieldset>
            </form>
    
        </div>
    
        <div class="spacer"></div>

    <br/>
    <xsl:choose>
      <xsl:when test="sum(//verificationtime)>0">
        <xsl:text> </xsl:text> <A href="selenium_log.txt">selenium_log</A>
        <xsl:text> </xsl:text> <A href="URLs.txt">URLs</A>
        <xsl:text> </xsl:text> <A href="TransferSize.txt">TransferSize (small tests only) </A>
      </xsl:when>
    </xsl:choose>

    <table>

    <tr class="header_row">
      <th>id</th>
      <th>Test Step</th>
      <th>Result</th>
      <th>Time</th>
      <xsl:choose>
        <xsl:when test="sum(//baselinematch)>0">
          <th>Image Match</th>
        </xsl:when>
      </xsl:choose>
    </tr>

    <xsl:for-each select="results/testcases/testcase">
    <!--	Set a variable to hold the href link -->
    <xsl:variable name="step_number"><xsl:value-of select="@id"/></xsl:variable>

   	  <xsl:choose>
        <xsl:when test="section">
            <tr class="section">
                <td></td>
                <td><xsl:value-of select="section"/></td>
                <td></td>
                <td></td>
                <xsl:choose>
                    <xsl:when test="sum(//baselinematch)>0">
                        <td></td>
                    </xsl:when>
                </xsl:choose>
            </tr>
        </xsl:when>
      </xsl:choose>

    <tr class="step_result">
      <td><a class="link_number" href="{$step_number}.html" target="_blank"><xsl:value-of select="@id"/></a></td>
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
          <td class="fail"> <xsl:text>FAIL</xsl:text> </td>
        </xsl:when>
        <xsl:when test="result-message='TEST CASE PASSED'">
          <td class="pass"> <xsl:text>PASS</xsl:text> </td>
        </xsl:when>
        <xsl:when test="contains($message,'RETRYING...')">
          <td class="retry"><xsl:value-of select="result-message"/></td>
        </xsl:when>
        <xsl:when test="contains($message,'RETRYING FROM STEP')">
          <td class="retry"><xsl:value-of select="result-message"/></td>
        </xsl:when>
        <xsl:otherwise>
          <td class="sanity"><xsl:value-of select="result-message"/></td>
        </xsl:otherwise>
      </xsl:choose>
     	<xsl:choose>
        <xsl:when test="responsetime>90">
          <td class="extremeslow"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:when test="responsetime>30">
          <td class="veryslow"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:when test="responsetime>5">
          <td class="slow"> <xsl:value-of select="responsetime"/> </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="normal"><xsl:value-of select="responsetime"/></td>
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

                 <xsl:for-each select='*[contains(name(), "verifynegative")]'>
                   <xsl:choose>
                     <xsl:when test="descendant::success='false'">
                       <td class="fail">
                         <xsl:choose>
                           <xsl:when test="descendant::message">
                             <xsl:value-of select="descendant::message"/>
                           </xsl:when>
                           <xsl:otherwise>
                             <xsl:text>FOUND: </xsl:text>
                             <xsl:value-of select="descendant::assert"/>
                           </xsl:otherwise>
                         </xsl:choose>
                       </td>
                     </xsl:when>
                   </xsl:choose>
                 </xsl:for-each>

                 <xsl:for-each select='*[contains(name(), "verifypositive")]'>
                   <xsl:choose>
                     <xsl:when test="descendant::success='false'">
                       <td class="fail">
                         <xsl:choose>
                           <xsl:when test="descendant::message">
                             <xsl:value-of select="descendant::message"/>
                           </xsl:when>
                           <xsl:otherwise>
                             <xsl:text>EXPECTED: </xsl:text>
                             <xsl:value-of select="descendant::assert"/>
                           </xsl:otherwise>
                         </xsl:choose>
                       </td>
                     </xsl:when>
                   </xsl:choose>
                 </xsl:for-each>
                    

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

    <tr class="footer_row">
      <th></th>
      <th></th>
      <th></th>
      <th>
        <xsl:value-of  select='format-number(sum(//responsetime), "###,##0.#")' /> 
        <xsl:text>s </xsl:text>
      </th>
      <xsl:choose>
        <xsl:when test="sum(//baselinematch)>0">
          <th align="left">Image Match</th>
        </xsl:when>
      </xsl:choose>
    </tr>

    </table>
    <br/>
  </body>
  </html>
</xsl:template></xsl:stylesheet>