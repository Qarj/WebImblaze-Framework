# WebInject Framework 0.03 Manual

# wif.config

This configuration file tells wif.pl where to find various components that it needs.

It also used by wif.pl to store some of the command line options you chose the last time you
invoked wif.pl. The next time you run wif.pl, it will use those options as a default.

## [main] config

### batch
The batch name to group run results under. Updated by wif.pl --batch option.

### environment
The high level environment name, e.g. DEV, PAT or PROD. Updated by wif.pl --env option.

### is_automation_controller
`true` if this machine is a company automated testing controller, `false` otherwise.

`true` means that WebInject `automationcontrolleronly` test steps will be run. Otherwise they
will be skipped.

### target
Target 'mini-environment' for the test case file. Update by wif.pl --target option.

### use_browsermob_proxy
`true` means run any Selenium WebDriver tests through BrowserMob Proxy.

You should ensure this option is set to `false` in most circumstances.

## [path] config

### browsermob_proxy_location_full
Where to find `browsermob-proxy.bat`. If you are not using BrowserMob Proxy, it is safe to leave this option at the default, even if is not installed.

### selenium_location_full
Where to find the Selenium Standalone Server JAR file. If you are not using Selenium WebDriver it is safe to leave this option at the default, even if is not installed.

### testfile_full
The last test case file that was run. Updated by wif.pl.

### web_server_location_full

Since wif.pl publishes the test run results to a web server for viewing, you need to
specify the root folder location.

On Windows, the default IIS server location is at 'C:\inetpub\wwwroot'

### webinject_location

Where to find webinject.pl, relative to where wif.pl is located. If you have placed them
in the same folder, you can simply specify `./`

### web_server_address

This is the base domain (and optionally port) where you will be able to access the results
through a web browser.

For testing wif.pl on your own machine, you can simply put in `localhost`

If you are running the web server on a port other than 80, it can be specified like this `localhost:8080`

# environment_config

In the folder you can give wif.pl information about your "website under test" web servers, account names, passwords, and any other details that your WebInject tests need.

The information is specified in a hierarchical way. This means it is possible to have many
'mini-environments' without having to repeat information that is common to each of the mini-environments.

It is often the case in a development environment that you have many teams where each team
has some of their own components, yet shares many other lesser used or lesser changed components with other teams.

## Level 1: environment_config/_global.config

_global.config contains configuration common to all environments.

## Level 2: environment_config/DEV.config /PAT.config /PROD.config

All other .config files directly in this folder refer to high level environment names.

In the provided example, three environments have been defined:
* DEV - development
* PAT - production acceptance test
* PROD - production

For wif.pl quick start purposes, you can leave this as it is.

## Level 3: environment_config/DEV/team1.config etc.

You create sub folders for each high level environment. In there you can create .config
files for each 'mini-environment' as needed. You need to create at least one
mini-environment.

In the provided example, there is an environment called WebInject_examples.config.

Note that for any configuration item provided at a lower level, it will take precedence
over the same configuration specified at a higher level.

## Sections within the configuration files

### [main]
Refer to the WebInject Manual, Configuration section.

In this section you can specify values for:
* proxy
* useragent
* httpauth
* baseurl, baseurl1, baserurl2
* timeout
* globalretry
* globaljumpbacks
* testonly
* autocontrolleronly

Important - if you do not want to set a value, it is better to delete the value rather than set it as blank. Otherwise WebInject may try to use a null value and fail.

### [userdefined]
Refer to the WebInject Manual, Configuration section.

In a nutshell, you can make up your own configuration items. So if you had `google=www.google.co.uk` you could refer to it in the
WebInject tests as `{GOOGLE}`.

### [autoassertions] and [smartassertions]
Refer to the WebInject Manual, Configuration section.

There examples in the example config - you can just delete them if you do not want them.

## DEV, PAT, PROD/_alias.config

In each of the example environment config folders, there is an example _alias.config file containing
alternate names for the 'mini-environments'.

It is possible to set up as many you want, so long as the value on the right hand side matches
a .config file in the same folder.
