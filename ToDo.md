# ToDo

<br />


## \RunTest.pl

### MVP
* read options
* create master temp folder in project with a .gitignore
* generate a random folder name suffix for test output
* create random folder under \temp
* ensure a high level environment name was supplied, e.g. DEV, LIVE, if not, display usage
* ensure a target sub environment name (e.g. server) was supplied
* ensure a target testfile was supplied
* see if a batch file name was supplied, if not, default to NoBatch
* determine web publish location, if none default to inetpub\wwwroot if possible, otherwise error
* default config file to basic config.xml for now
* determine the run number for today
* run the test cases with WebInject.pl
* prepend stylesheet to results file
* Put the results on the webserver
* call script to split http.log into one html file for each test step
* create a batch summary record to indicate overall run result (removing the pending records)

### Later
* see if an option was supplied to ignore retry
* check if target environment needs to be converted from friendly name to server name
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


