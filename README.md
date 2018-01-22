# WebInject Framework 1.08

Automated regression testing framework for
* managing WebInject configuration
* running many WebInject automated tests in parallel
* organising actual test run results for many teams and test case files

This framework is for those with large suites of automated tests. It helps to quickly
answer the question "Did all of our regression tests pass?".

If the answer is no, you can very quickly drill into what went wrong. Since an organised history of previous run results are kept,
you can compare a failed result easily against a previous successful run.

You can see WebInject example output here: http://qarj.github.io/WebInject-Example/

# Quick Start Guide - 5 minutes to install and use!

## Windows Installation

1. Install WebInject. (refer to https://github.com/Qarj/WebInject)

2. Clone the project
    ```
    mkdir C:\git
    cd /D C:\git
    git clone https://github.com/Qarj/WebInject-Framework.git
    ```

3. From an Administrator command prompt:
    ```
    cpan Config::Tiny
    ```

4. Press the windows key and type `Turn Windows` then select the menu item `Turn Windows Features on or Off`. Ensure `Internet Information Services` (IIS) is turned on.

That's it! You are now ready to run your first WebInject test using the WebInject Framework.

## Linux

Linux is not yet supported.

## running wif.pl - minimal example

Open the command prompt up as an Administrator.

Now create the wif.config file, a default one can be created with this command
```
wif.pl --create-config
```
You don't need to change the default settings for this example to work.

To run an automated test, wif.pl needs to know the:
* test file to run
* high level environment
* target 'mini-environment' - team name (has own web server, but sharing a development database with other teams)

```
wif.pl example_test --env DEV --target team1
```

If everything worked ok, wif.pl created a configuration file for WebInject, called
WebInject, ran the tests, then put all the results in your web server location.

You can view the results by going to http://localhost/DEV/Summary.xml

Since wif.pl will remember the last test file you ran, and environment details, you
can run it again as follows:

```
wif.pl
```

If you want to run another example, since the environment details have not changed,
you can just specify the test case file:

```
wif.pl ../WebInject/examples/hello
```

The WebInject framework will search for the test case file that is the best match and run it.
```
wif.pl examples/hello
```
Will also work, and even
```
wif.pl hello
```

Finally, let's run another example, but store the result under a batch name:
```
wif.pl examples/post.xml --batch my_team_results
```

## Viewing the test run results

You can view and drill into the results from this url:

http://localhost/DEV/Summary.xml

Click on a batch to see individual test results for the batch.

Click on the Run number (first column) to see the individual step results for a test case file.

From the test case file results, click on the id number (first column), to see that step actual result.

# Running tests in parallel

The point of the WebInject-Framework is to run a lot of tests quickly and check that there are no failures.

To see this in action, go and first install the Selenium plugin for WebInject https://github.com/Qarj/WebInject-Selenium

Now run the all of the WebInject examples
```
tasks\Examples.pl
```

You'll see a lot of command prompts open, run some tests then close, all at the same time.

Note that when you view the results at http://localhost/DEV/Summary.xml
you'll see a lot of errors. Many of the examples show how various assertions work, and how tests can be automatically
retried on failure.

In practice, the tests should be run by a service account. You can use Windows Task Scheduler to run the tests overnight.

You can run all the WebInject selftests quickly as follows:
```
tasks\Selftest.pl
```

Note that the tasks\ scripts can take parameters too
```
tasks\Examples.pl --env DEV --target team2 --batch My_Examples
```

## Pending results
While the tests are running, you can see intermediate results. Just go the results Summary page, click
on the batch, and see the pending results. You can press F5 as results complete to see the latest
completions.

On a pending result, you can click on the Started date/time for a test file and see where it is up to. Again
just press F5 to get the latest update.

# The WebInject Framework Manual

The manual contains full details on how to setup WebInject Framework.

[WebInject Framework Manual - MANUAL.md](MANUAL.md)
