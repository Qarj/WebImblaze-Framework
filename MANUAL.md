# WebImblaze Framework 1.13.2 Manual

# wif.config

This configuration file tells wif.pl where to find various components that it needs.

You can create a config file with default values to get you started as follows:

```
wif.pl --create-config
```

The `wif.config` file is also used by wif.pl to store some of the command line options you chose the last time you invoked wif.pl. The next time you run wif.pl, it will use those options as a default.

An example `wif.config` looks like this:

```
[main]
batch=example_batch
environment=DEV
is_automation_controller=false
target=team1

[path]
selenium_location_full=C:\selenium\selenium-server-3-standalone.jar
chromedriver_location_full=C:\selenium\chromedriver.exe
driver=chromedriver
testfile_full=../WebImblaze/examples/get.test
web_server_address=localhost
web_server_location_full=C:\Apache24\htdocs
webimblaze_location=../WebImblaze
output_location=./temp/
```

## [main] config

### batch

The batch name to group run results under. Updated by `wif.pl --batch` option.

### environment

The high level environment name, e.g. DEV, PAT or PROD. Updated by `wif.pl --env` option.

### is_automation_controller

`true` if this machine is a company automated testing controller, `false` otherwise.

`true` means that WebImblaze `automationcontrolleronly` test steps will be run. Otherwise they will be skipped.

This feature gives you a way of developing and running your tests on a workstation while skipping any tests
that are not possible to run from your local environment.

### target

Target 'mini-environment' for the test case file. Update by `wif.pl --target` option.

For example, the mini environment might be the name of a team within your development environment.

## [path] config

### chromedriver_location_full

Where to find the chromedriver binary. If you do not have Selenium tests, this value does not matter.

```
chromedriver_location_full=C:\selenium\chromedriver.exe
```

### driver

Browser driver to use, current choices are `chrome` (i.e. Selenium Server) or `chromedriver` (Selenium Server or Java not needed).

```
driver=chromedriver
```

### output_location

Where `wi.pl` should output to.

```
output_location=./temp/
```

### selenium_location_full

Where to find the Selenium Standalone Server JAR file. If you are not using Selenium WebDriver it is safe to leave this option at the default, even if is not installed.

```
selenium_location_full=C:\selenium\selenium-server-standalone-2.53.1.jar
```

### testfile_full

The last test case file that was run. Updated by wif.pl.

```
testfile_full=tests/totaljobs/mytotaljobs.xml
```

### web_server_address

This is the base domain (and optionally port) where you will be able to access the results through a web browser.

For testing wif.pl on your own machine, you can simply put in `localhost`.

If you are running the web server on a port other than 80, it can be specified like this `localhost:8080`.

```
web_server_address=my-server.example.com
```

### web_server_location_full

Since wif.pl publishes the test run results to a web server for viewing, you need to specify the root folder location.

```
web_server_location_full=C:\Apache24\htdocs
```

### webimblaze_location

Where to find `wi.pl`, relative to where `wif.pl` is located. If you have placed them in the same folder, you can simply specify `.`.

```
webimblaze_location=.
```

# environment_config folder

In this folder you can give wif.pl information about your "website under test" web servers, account names, passwords, and any other details that your WebImblaze tests need.

The information is specified in a hierarchical way. This means it is possible to have many 'mini-environments' without having to repeat information that is common to each of the mini-environments.

It is often the case in a development environment that you have many teams where each team has some of their own components, yet shares many other lesser used or lesser changed components with other teams.

You can call the environments and individual config files anything you want. You can have as many environments and sub-environments as you need.

Only `_global.config` cannot be renamed.

## Level 1: environment_config/\_global.config

\_global.config contains configuration common to all environments.

\_global.config example:

```
[autoassertions]
autoassertion1=HTTP Error 404.0 . Not Found|||Page not found error
autoassertion2=HTTP Error 500.0 . Not Found|||Server error

[smartassertions]
smartassertion1=Set\-Cookies: |||Cache\-Control: private|Cache\-Control: no\-cache|||Must have a Cache-Control of private or no-cache when a cookie is set

[main]
globalretry=50
globaljumpbacks=15
autoretry=0

[userdefined]
totaljobs=www.totaljobs.com
wic=webimblaze-check.azurewebsites.net

[baseurl_subs]
https_to_http_remap=https:(.+):8080|||"http:".$1.":4040"

[content_subs]
stop_refresh=HTTP-EQUIV="REFRESH"|||"HTTP-EQUIV=___WIF___"
```

## Level 2: environment_config/DEV.config /PAT.config /PROD.config

All other .config files directly in this folder refer to high level environment names.

In the provided example, three environments have been defined:

-   DEV - development
-   PAT - production acceptance test
-   PROD - production

For wif.pl quick start purposes, you can leave this as it is.

DEV.config example:

```
[main]
testonly=true
ntlm=.dev.com:8020::DEV\JXS-SCT001:password

[userdefined]
domain=.dev.com
high_level_environment_name=DEV
backoffice_password=password1
postcode_api_password=password2
template_id=554433
client_id=AABBCCEA-AECD-432F-84B2-07214F3C12E2
testonly=true
```

## Level 3: environment_config/DEV/team1.config etc.

You create sub folders for each high level environment. In there you can create .config files for each 'mini-environment' as needed. You need to create at least one mini-environment.

In the provided example, there is an environment called WebImblaze_examples.config.

Note that for any configuration item provided at a lower level, it will take precedence over the same configuration specified at a higher level.

Level 3 config example (e.g. DEV/skynet.config):

```
[main]
ntlm=.skynet.com:8020::SKYNET\JXS-SCT001:password
deny_access=true
globalretry=42

[userdefined]
team_name=skynet
content_server=server666
adsensemode=,"adtest":"debug"

[autoassertions]
autoassertion1=HTTP Error 404.0 . Not Found|||Page not found error
autoassertion5=Java Stacktrace Error|||Java Abend
```

## Sections within the configuration files

### [main]

Refer to the WebImblaze Manual, Configuration section.

In this section you can specify values for:

-   useragent
-   httpauth
-   baseurl, baseurl1, baserurl2
-   timeout
-   globalretry
-   globaljumpbacks
-   autocontrolleronly
-   autoretry
-   windows_sys_temp
-   windows_app_data
-   linux_sys_temp
-   linux_app_data

Important - if you do not want to set a value, it is better to delete the value rather than set it as blank. Otherwise WebImblaze may try to use a null value and fail.

### [userdefined]

Refer to the WebImblaze Manual, Configuration section.

In a nutshell, you can make up your own configuration items. So if you had `google=www.google.co.uk` you would refer to it in the WebImblaze tests as `{GOOGLE}`.

### [autoassertions] and [smartassertions]

Refer to the WebImblaze Manual, Configuration section.

There examples in the example config - you can just delete them if you do not want them.

### [baseurl_subs]

WebImblaze creates an html file for every step result. WebImblaze will remap the http references in the html source back to the web server under test using the page baseurl. Sometimes you may want to tweak the urls - for example, change https references to http to get around test environment ssl certificate issues.

Here is an example substitution:

```
https_to_http_remap=https:(.+):8080|||"http:".$1.":4040"
```

On the left hand side, LHS, of the three bars, we have the LHS of the regex. On the right hand side, RHS, we have the RHS of the regex substitution in the form of a Perl expression.

### [content_subs]

To change the step html response content, you can specify regular expressions in this section. They work in the same way as described in [baseurl_subs].

Why would you want to do this? Some pages will try to redirect to somewhere else. Obviously this is not desirable since we want to see the actual result. So we do a substitution to break the redirect.

Here is a very common example:

```
stop_refresh=HTTP-EQUIV="REFRESH"|||"HTTP-EQUIV=___REDIRECT_BLOCKED_BY_WEBIMBLAZE___"
```

## DEV, PAT, PROD/\_alias.config

In each of the example environment config folders, there is an example `_alias.config` file containing alternate names for the 'mini-environments'.

It is possible to set up as many you want, so long as the value on the right hand side matches a `.config` file in the same folder.

# wif.pl command line options

Typical example

```
wif.pl example_test --env DEV --target team1 --batch My_Tests
```

The WebImblaze-Framework will search all sub folders of tests/ for a file called `example_test.xml`. If it doesn't find it, it will also search (plus subfolders)

```
../WebImblaze
../WebImblaze-Selenium
```

To run the same test again, just issue

```
wif.pl
```

## `wif.pl --version`

## `wif.pl --help`

## `wif.pl tests/mytest.xml`

Runs the tests in mytest.xml.

## `wif.pl mytest`

Will search sub folders of `./` for mytest.xml and will run the first one found.

## `wif.pl --target my_team`

Sets the 'mini-environment' to `my_team` and runs the last test with the saved options.

## `wif.pl --batch Priority_1_Tests`

Sets the batch to `Priority_1_Tests` and runs the last test with the saved options.

## `wif.pl --env PROD`

Sets the environment to PROD and runs the last test with the saved options.

## `--selenium-host`

Passes the Selenium (Grid) host to `wi.pl`.

## `--selenium-port`

Passes the Selenium (Grid) port to `wi.pl`.

## `--headless`

Tells `wi.pl` to run Selenium Chrome tests in headless mode.

## `--no-retry`

Tells WebImblaze to ignore the `retry` and `retryfromstep` parameters.

## `--no-update-config`

Tells wif.pl not to update wif.config with the current options. Important for running many tests in parallel - otherwise competing instances of wif.pl will try to update the wif.config file at the same time - and cause unknown problems.

## `--capture-stdout`

When running through the command line, you'll see wi.pl and wif.pl go straight to the command prompt. However when running a large set of tests from a service account, you will want the STDOUT output to be captured.

## `--keep`

Tells wif.pl not to delete the temporary folder it created for WebImblaze's temporary files. For debug purposes.

## `--keep-session`

Passes this option to `wi.pl` which tells it to remember the Selenium session information and not close Selenium and the browser at the end of the run.

## `--resume-session`

If `--keep-session` was used in the previous run, then `wi.pl` will attempt to connect to the existing Selenium session and browser and run the tests from the existing state.

This is useful for debugging very long workflows where there is a problem deep into the workflow and you do not want to run the entire workflow to try various ideas to get your test step working.

## `--create-config`

Creates (or overwrites) the wif.config with default values to get you started.

# tasks/ folder

The tasks folder contains a script called `Examples.pl` that runs all of the WebImblaze examples at the same time.

If you "start" a test, a new process will be created to run that test. This enables you to run many tests in parallel.

If you "call" a test, that test will be run 'in-process' meaning that the test must finish before the script proceeds.

## Minimal Example

```
tasks\Examples.pl --env DEV --target team1 --batch Examples
```

All the tests referred to in Examples.pl will be run. The environment is `environment_config/DEV.config`, the target is `environment_config/DEV/team1.config`, the batch name is `Examples`.

## Example to only run the task if a certain URL is reachable

```
tasks\Examples.pl --check-alive http://www.example.com --env DEV --target team1 --batch Examples
```

Before the tests are run, the url `http://www.example.com` will be checked to ensure that a response is returned. If there is no response, no tests will be run.

## Example with alert to Slack on failure

Note: If the batch still has not finished after 15 minutes, it will give up waiting and alert the current status.

```
tasks\Examples.pl --env PROD --target server_9101 --batch Monitor --slack-alert https://hooks.slack.com/services/ABCDE/FGHIJ/A6qrs3Jnq225p
```

## Example which only runs a test file if the group matches

Say you had a tasks file called `tasks\myRegression.pl` with the following content:

```
Runner::start('../tests/regression/register.xml', ['Bear', 'Frog']  );
Runner::start('../tests/regression/purchase.xml', ['Bear'] );
Runner::start('../tests/regression/profile.xml');
```

Then if you ran it with the `--group` parameter:

```
tasks\myRegression.pl --group Bear
```

It would run:

-   `register.xml` - since there is a matching group
-   `purchase.xml` - ditto
-   `profile.xml` - since no groups are specified, default - run it

Another example:

```
tasks\myRegression.pl --group Frog
```

Would run `register.xml` and `profile.xml` but not `purchase.xml`.

And if you do not specify the --group option at all, then all test files would be run.

# Syntax Highlighting WebImblaze test case files

## Visual Studio Code

By far the easiest to install - just search for `WebImblaze` in extensions, install, and you are done.

The VSCode syntax highlighting is the most complete, accurate, and best looking out of these options.

## Notepad++

_If you've done this previously and are updating - delete the existing WebImblaze language first._

It is worth spending two minutes to set up WebImblaze syntax highlighting in Notepad++

-   Select menu `Language -> Define your language ...`
-   Click `Import...`
-   Select file `WebImblaze-Framework/tools/webimblaze_notepad++.xml`
-   Restart Notepad++

It looks much, much better if you use a dark theme.

-   Select menu `Settings -> Style Configurator...`
-   Set `Select theme :` to `Plastic Code Wrap`
-   _Important_ - check `Enable global background colour`
-   _Important_ - check `Enable global font`
-   _Important_ - check `Enable global bold font style`
-   If you have it available, `DejaVu Sans Mono` is a nice font
-   Click `Save & Close`
-   Restart Notepad++

Note that Material-Dark is a nice theme:

https://github.com/naderi/material-theme-for-npp

-   In Windows Explorer, go to `%AppData%\Notepad++\themes`
-   Copy the file `WebInject/tools/Material-Dark.xml` to that location
-   Restart Notepad++ then select that them from `Settings -> Style Configurator...`
-   Increase the font size slightly improves the appearance a lot

## UltraEdit

In the tools folder, the `webimblaze.uew` file is an UltraEdit word file which you can use with UltraEdit to highlight WebImblaze test case files - it makes it much easier to be certain that you are using the right keyword / parameter.

# Convert WebInject .xml test case files to WebImblaze .test format

The script `tools/transmute.pl` will output a WebInject style xml test file in the WebImblaze format.

Example usage (assuming you have `transmute.pl` in path):

```
transmute.pl MyTest.xml > MyTest.test
```
