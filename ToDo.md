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

### Later
X display most recent file run / server
* check if xml results can be parsed - if not, error processing
* check if error after running WebInject.pl
* see if an option was supplied to ignore retry
* check if target environment needs to be converted from friendly name to server name
* read environment name from wif.config
* read default proxy from config
* get target server from wif.config
* get high level environment from config - e.g. DEV, LIVE, default to DEV
* check for administrative permissions
* display process id?
* determine if this is the automation controller
* default high level environment
* default low level environment
* call a script to generate the configuration file
* update the pending record to indicate execution has started
* remove previous http.log, if present (redundant?)
* option to not delete temporary files
* check that test file xml is valid (subscript or sub?)
* check to see if webinject aborted, if so, need dummy result to indicate issue
* check results file to see if it is valid, if not, need dummy result to indicate issue
* call script to remmove viewstates (needed?)
* determine the run number for today
* prepend stylesheet to results file
* Put the results on the webserver
* call script to split http.log into one html file for each test step
* can locate where webinject.pl is and be in same folder
* create a batch summary record to indicate overall run result (removing the pending records)
* read which selenium server to use from config
* support specify selenium server location / full 
* support read chromedriver from  config file
* write har.gzip directly to web server
* comment out har file as plain text - it is for debug use only

### More later

* shutdown browsermob_proxy by default
* option to keep browsermob_proxy running

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
