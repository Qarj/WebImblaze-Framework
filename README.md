# WebImblaze-Framework 1.09

Automated regression testing framework for
* managing WebImblaze configuration
* running many WebImblaze automated tests in parallel
* organising actual test run results for many teams and test case files

This framework is for those with large suites of automated tests. It helps to quickly
answer the question "Did all of our regression tests pass?".

If the answer is no, you can very quickly drill into what went wrong.
Since an organised history of previous run results are kept,
you can compare a failed result easily against a previous successful run.

You can see WebImblaze example output here: http://qarj.github.io/WebInject-Example/

# Quick Start Guide - 5 minutes to install and use!

## Linux

Open a terminal then install system packages root.
```
sudo apt update
sudo apt --yes install gnome-terminal
sudo apt --yes install apache2
sudo apt --yes install apache2-dev
```

Install WebImblaze (refer to https://github.com/Qarj/WebImblaze).

Clone the project.
```
cd /usr/local/bin
sudo git clone https://github.com/Qarj/WebImblaze-Framework.git
```

Set permissions.
```
cd /usr/local/bin/WebImblaze-Framework
sudo find . -type d -exec chmod a+rwx {} \;
sudo find . -type f -exec chmod a+rw {} \;
sudo chmod 777 /var/www/html
```

Restart Apache and make sure there are no error messages.
```
sudo systemctl restart apache2
```

Install Perl packages required by `wif.pl`.
```
sudo cpan Config::Tiny
sudo cpan File::Find::Rule
```

Create `wif.config`.
```
perl wif.pl --create-config
```

Optional - edit the config file, and change the `web_server_address` parameter from `localhost` to the DNS name of the server.
```
vi wif.config
```
If you don't do this, you won't be able to access the results from outside this server.


Confirm that you can view the help without error messages.
```
perl wif.pl --help
```

Run the canary checks too.
```
perl wif.pl canary/canary.test
```

## Windows Installation

Install WebImblaze. (refer to https://github.com/Qarj/WebImblaze).

Clone the project.
```
cd /D C:\git
git clone https://github.com/Qarj/WebImblaze-Framework.git
```

Install Perl packages required by `wif.pl`.
```
cpan Config::Tiny
```

Now install let's install Apache for windows.

First we need to ensure that IIS isn't installed and running.
Press the windows key and type `Turn Windows` then select the menu item `Turn Windows Features on or Off`.
Ensure `Internet Information Services` (IIS) is turned off. (On Windows 10 it is turned off by default).

From Apache Lounge https://www.apachelounge.com/download/ download Win32 zip file - not 64 bit, then extract so C:\Apache24\bin folder is available.

Then open a command prompt as Administrator.
```
cd C:\Apache24\bin
httpd -k install
httpd -k start
```

Now create the `wif.config` file.
```
cd /D C:\git\WebImblaze-Framework
perl wif.pl --create-config
```
You don't need to change the default settings for this example to work.

Find out the DNS name of this server.
```
echo %COMPUTERNAME%.%USERDNSDOMAIN%
```

Edit the config file, and change the `web_server_address` parameter from `localhost` to the DNS name of the server.
```
notepad wif.config
```
If you don't do this, you won't be able to access the results from outside this server.

That's it! You are now ready to run your first WebImblaze test using the WebImblaze Framework.

## running wif.pl - minimal example

Open the command prompt up as an Administrator.

To run an automated test, wif.pl needs to know the:
* test file to run
* high level environment
* target 'mini-environment' - team name (has own web server, but sharing a development database with other teams)

```
perl wif.pl example_test --env DEV --target team1
```

If everything worked ok, wif.pl created a configuration file for WebImblaze, called
WebImblaze, ran the tests, then put all the results in your web server location.

You can view the results by going to http://localhost/DEV/Summary.xml

Since wif.pl will remember the last test file you ran, and environment details, you
can run it again as follows:

```
perl wif.pl
```

If you want to run another example, since the environment details have not changed,
you can just specify the test case file:

```
perl wif.pl ../WebImblaze/examples/hello
```

The WebImblaze framework will search for the test case file that is the best match and run it.
```
perl wif.pl examples/hello
```
Will also work, and even
```
perl wif.pl hello
```

Finally, let's run another example, but store the result under a batch name:
```
perl wif.pl examples/post.xml --batch my_team_results
```

## Viewing the test run results

You can view and drill into the results from this url:

http://localhost/DEV/Summary.xml

Click on a batch to see individual test results for the batch.

Click on the Run number (first column) to see the individual step results for a test case file.

From the test case file results, click on the id number (first column), to see that step actual result.

# Running tests in parallel

The point of the WebImblaze-Framework is to run a lot of tests quickly and check that there are no failures.

To see this in action, go and first install the Selenium plugin for WebImblaze https://github.com/Qarj/WebImblaze-Selenium

Now run the all of the WebImblaze examples
```
perl tasks\Examples.pl
```

You'll see a lot of command prompts open, run some tests then close, all at the same time.

Note that when you view the results at http://localhost/DEV/Summary.xml
you'll see a lot of errors. Many of the examples show how various assertions work, and how tests can be automatically
retried on failure.

In practice, the tests should be run by a service account. You can use Windows Task Scheduler to run the tests overnight.

You can run all the WebImblaze selftests quickly as follows:
```
perl tasks\Selftest.pl
```

Note that the tasks\ scripts can take parameters too
```
perl tasks\Examples.pl --env DEV --target team2 --batch My_Examples
```

## Pending results
While the tests are running, you can see intermediate results. Just go the results Summary page, click
on the batch, and see the pending results. You can press F5 as results complete to see the latest
completions.

On a pending result, you can click on the Started date/time for a test file and see where it is up to. Again
just press F5 to get the latest update.

# The WebImblaze Framework Manual

The manual contains full details on how to setup WebImblaze Framework.

[WebImblaze Framework Manual - MANUAL.md](MANUAL.md)
