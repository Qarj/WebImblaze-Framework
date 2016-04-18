# ToDo

<br />


## \wif.pl

### MVP
X read options
X create master temp folder in project with a .gitignore
X generate a random folder name for test output
X ensure there is a temp folder - it is checked into git
X create random folder under \temp
X ensure high level environment name supplied e.g. DEV, PAT, LIVE, default to DEV
X target = ensure a target sub environment name (e.g. server) was supplied
X ensure a target testfile was supplied
X ensure target testfile exists
X see if a batch file name was supplied, if not, default to Default_Batch
X determine web publish location
X determine if this is the automation controller
X call subs\get_config_file_name.pl :: wif version will always return config.xml
X call subs\get_run_number.pl :: wif version will always return 1001
X call subs\check_testfile_xml_parses_ok.pl :: wif version will always pass
X call subs\write_pending_results.pl :: wif version will do nothing
X run the test cases with WebInject.pl
X call subs\publish_results_on_web_server.pl :: wif version will do nothing
X call subs\write_final_result.pl :: wif version will do nothing
X call subs\publish_static_files.pl :: wif version will do nothing
X call subs\hard_exit_if_chosen.pl - not required - this problem does not exist
X remove temporary folder
X can supply a flag for keeping temporary files
X call subs_get_webinject_location.pl
X check if testcase file contains selenium
X support to use proxy or not [false]
X support ignore retry
X hard code browser selection to chrome
X support start of a proxy
X start selenium server with chromedriver
X run tests with selenium options
X stop sel server with chromedriver
X shut down dynamic port for the run
X write har file
X write out urls in har file
X compress har
X do not support automatic retry of the entire file
X fix structure of other subs to return at start if should not be executed
X option to not delete temporary files

X make subs\get_webinject_location.pl
X make subs\get_web_server_location.pl
X make subs\get_automation_controller_flag.pl
X make subs\get_config_file_name.pl (convert friendly name to server name)
X make subs\get_run_number.pl
X make subs\check_testfile_xml_parses_ok.pl
X make subs\write_pending_result.pl
X make subs\publish_results_on_web_server.pl (will also copy png and jpg and js files over) (will copy and split http log) (will prepend stylesheet)
X make subs\write_final_result.pl
X make subs\publish_static_files.pl

wif.pl testcases\research\test.xml --target enzo
wif.pl testcases\research\selenium.xml --target enzo --proxy
01-Run A PAT pat research test B1

### Later
X display most recent file run / server
X display run number in title
X see if an option was supplied to ignore retry
X read environment name from wif.config
X read proxy flag from config
X get target server from wif.config
X get high level environment from config - e.g. DEV, LIVE, default to DEV
X update config with most recent run (target server, environment)
X read which selenium server to use from config
* support read chromedriver from config file
X save config with options
X option not to save config

X Remove check_testfile_xml_parses_ok.pl
X   X check that test file xml is valid (subscript or sub?)

X Remove get_web_server_location.pl
X   X can locate where webinject.pl is and be in same folder

X Remove get_automation_controller_flag.pl
X   X determine if this is the automation controller

X Remove get_config_file_name.pl
X   X check if target environment needs to be converted from friendly name to server name
X   X call a script to generate the configuration file

X Remove get_run_number.pl
X   X determine the run number for today

X Remove write_pending_result.pl
X   X update the pending batch record to indicate execution has started
X   X update summary of batches record too

X Remove get_webinject_location.pl

X Remove start_browsermob_proxy.pl

X Remove publish_results_on_web_server.pl
X   X prepend stylesheet to results file
X   X Put the results on the webserver

X Remove write_final_result.pl
X   X create a batch summary record to indicate overall run result (removing the pending records)

X Create sub check_webinject_ran_ok
X   X check if xml results can be parsed - if not, error processing
X   X check if error after running WebInject.pl
X   X check to see if webinject aborted, if so, need dummy result to indicate issue
X   X check results file to see if it is valid, if not, need dummy result to indicate issue

* Remove publish_static_files.pl
    X Summary.xsl -> Summary.xsl
        X Bug - Only latest?
        X Links to other wif servers
        X css
        X Scroll up Down
        X fonts
        X light grey background?
        X CORRUPT
    X batch.xsl -> Batch.xsl
    * results.xsl -> Results.xsl
        X wildcard match on attribute names possible?
            - //*[substring(name(),string-length(name())-1) = 'fu'] - selects all elements in the xml document, whose names end with the string fu
            - <xsl:template match="*[substring(name(), string-length(name()) -8) = 'Nokia_5.0')]"> - selects all elements that end with Nokia_5.0
            - <xsl:template match='*[contains(name(), "Nokia_5.0")]'> - of if it just contains the wanted string
        X research if "image-success" and "image-message" support needed - no it is not
        X create a testfile with examples of all types of elements
        * make the stylesheet support each multi type
            - searchimage
            X verifynegative
            X verifypositive
            X autoassertion
            X smartassertion
        * make the style sheet support each single type
            X assertionskips
            - verifyreponsecode
            - result-message
            - responsetime
            - baselinematch
            - retry
            - retryfromstep
            - description1, description2
            - verifyresponsetime
            - verifyresponsecode
            - checkpositive
            - checknegative
            - checkresponsecode
            - sanitycheck
        X review colours of
            X verifypositive failure
            X verifynegative failure
        X Run time in header
        X Sum of response times in footer row
        X remove max response time
        X start time in header
        X Full http log and Results links styled as buttons (open in new tab)
        X text filter
        X fix color of links to test steps

* split http.log into one html file for each test step

* stress test file locking logic
   * 1 - start many instances of wif at the same time - say 20
   * 2 - put first test in loop for 10 mins

### More later

* shutdown browsermob_proxy by default
* option to keep browsermob_proxy running
* check for administrative permissions - or investigate privilleges required
* dealing with the SSL cert for browsermob proxy
* instructions for browsermob proxy installation
* setting up a website for results and BMP
* serving up .less files in website
* record traffic in HAR file
* write har.gzip directly to web server
* comment out har file as plain text - it is for debug use only
* supply an upstream proxy server to browsermob proxy
* set an exit code for wif, 0 all passed, 1 if errors

### Much Later
* support baseline folder [baseline]
* support browser selection [chrome]
* webinject http tests can also use browsermob proxy
* support not having proxy rules applied
* check if har file too big & report on bytes both gzip and not transferred during session
* support firefox
* support phantomjs
* start selenium server as hub (phantomjs)
* stop hub
* display pid
* searchimage
    - copy over baselined imageds
    - image-success
    - searchimage-success
* further styling on Summary.xml
    [ ] click for previous day and next day (if there is a next day) 
* need to fix corruption so overal batch summary message is xml corruption - element-available test does not work...
    
<br />


## \Content\results.xsl

### MVP
* Set a font, background colour
* show a results heading
* show summary info
* create a table
* show in re if the test case passed or failed, or was retried
* see if it is possible to do wildcards for matching attributes and displaying all of them - http://stackoverflow.com/questions/6104292/using-xpath-in-xsl-to-select-all-attribute-values-of-a-node-with-attribute-name
* also: http://stackoverflow.com/questions/27834472/xslt-and-dynamic-attribute-names

### Later
* create css
* format text between [] a special way
* format text starting with Info - a special way
* info re searchimage results

<br />


## \Scripts\split_httplog.pl (or sub?)

### MVP
* split the http.log into lots of little files

### Later

<br />


## \Scripts\summary.pl (or sub)

### MVP
* Create a batch summary record

### Regression.pl
* http://www.perlmonks.org/?node_id=936683 START
