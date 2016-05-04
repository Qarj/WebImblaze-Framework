# WebInject Framework 1.01

Automated regression testing framework for
* managing WebInject configuration
* running many WebInject automated tests in parallel
* organising actual test run results

This framework is for those with large suites of automated tests. It helps to quickly
answer the question "Did all of our regression tests pass?".

If the answer is no, you can very quickly drill into what went wrong. Since an organised history of previous run results are kept, you can compare a failed result easily against a previous successful run.

# Quick Start Guide - 5 minutes to install and use!

## Windows Installation

1. Install WebInject. (refer to https://github.com/Qarj/WebInject)

2. Click on Download ZIP to download WebInjectFramework as a zip file. Unzip WebInjectFramework
in a folder beside WebInject. Assuming you installed both WebInject and WebInjectFramework
at the root level, you will have the following files available:
  * C:\WebInject\webinject.pl
  * C:\WebInjectFramework\wif.pl


3. From an Administrator command prompt:
```
cpan Config::Tiny
```

4. Press the windows key and type `Turn Windows` then select the menu item `Turn Windows Features on or Off`. Ensure `Internet Information Services` is turned on.

That's it! You are now ready to run your first WebInject test using the WebInject Framework.

## running wif.pl - minimal example

To run an automated test, wif.pl needs to know the:
* test file to run
* high level environment
* target 'mini-environment'

```
wif.pl ../WebInject/examples/demo.xml --env DEV --target webinject_examples
```

If everything worked ok, wif.pl created a configuration file for WebInject, called
WebInject, ran the tests, then put all the results in your web server location.

Since wif.pl will remember the last test file you ran, and environment details, you
can run it again as follows:

```
wif.pl
```

If you want to run another example, since the environment details have not changed,
you can just specify the test case file:

```
wif.pl examples/get.xml
```

Finally, let's run another example, but store the result under a batch name:
```
wif.pl examples/post.xml --batch my_results
```

## Viewing the test run results

You can view and drill into the results from this url:

http://localhost/DEV/Summary.xml

# The WebInject Framework Manual

The manual contains full details on how to setup WebInject Framework.

[WebInject Framework Manual - MANUAL.md](MANUAL.md)
