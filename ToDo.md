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
* call subs\PendingResults.pl :: wif version will do nothing
* run the test cases with WebInject.pl
* check if error after running WebInject.pl
* call subs\PrependStylesheet.pl :: wif version will do nothing
* call subs\PublishResults.pl (will also copy png and jpg and js files over) (will copy and split http log) :: wif version will do nothing
* call subs\BatchSummary.pl :: wif version will do nothing
* call subs\UpdateStaticFiles.pl :: wif version will do nothing
* call subs\CleanupExit.pl :: wif version will do nothing
X remove temporary folder
* can supply a flag for keeping temporary files
* can supply a flag for no close

* make subs\get_web_server_location.pl
* make subs\get_automation_controller_flag.pl
* make subs\get_config_file_name.pl (convert friendly name to server name)
* make subs\get_run_number.pl
* make subs\check_testfile_xml_parses_ok.pl
* make subs\PrependResults.pl
* make subs\BatchSummary.pl
* make subs\UpdateStaticFiles.pl
* make subs\CleanupExit.pl


### Later
* see if an option was supplied to ignore retry
* check if target environment needs to be converted from friendly name to server name
* read environment name from wif.config
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
* create a batch summary record to indicate overall run result (removing the pending records)

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


