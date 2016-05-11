# WebInject Framework change log

Tim Buckland, https://github.com/Qarj/WebInjectFramework

---------------------------------
## Release History:

### Version 1.03 - May 11, 2016
* automatically switch environment if target not found but can be found an another environment

### Version 1.02 - May 11, 2016
* no longer have to cd to wif.pl folder before starting it
* use make_path to make folders, will not die if folder already exists
* fixed write batch summary record retry
* fixed a rare bug with processing the environment config

### Version 1.01 - May 4, 2016
* find test case file when folder not specified, and also without xml extension
* command line options now accepted for tasks --target and --batch
* tweaks to robustness with many parallel instances of wif.pl

### Version 1.00 - May 2, 2016
* fixed a bug with file unlocking
* STDOUT and STDERR for wif.pl and webinject.pl can be captured and linked to from the results
* workaround for Selenium server port 
* auto creates temp/ folder if needed
* tasks like Regression.pl do not need config files any more

### Version 0.03 - Apr 25, 2016
* improved file locking logic
* improved css styles
* introduced an option to capture STDOUT for both wif.pl and webinject.pl
* introduced Runner.pm can now run tests "in process" as well as starting a new process for each test

### Version 0.02 - Apr 23, 2016
* first release - fully functional WebInject Framework designed to organise WebInject configuration and test run results

### Version 0.01 - Jan 31, 2016
* project created
