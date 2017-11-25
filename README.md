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
wif.pl ../WebInject/examples/get.xml --env DEV --target team1
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

# The WebInject Framework Manual

The manual contains full details on how to setup WebInject Framework.

[WebInject Framework Manual - MANUAL.md](MANUAL.md)
