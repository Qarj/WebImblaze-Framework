# WebInject Framework 0.02

Framework for
* managing WebInject configuration
* running many WebInject automated tests in parallel
* organising actual test run results

This framework is for those with large suites of automated tests. It helps to quickly
answer the question "Did all of our regression tests pass?".

If the answer is no, you can very quickly drill into what went wrong. Since an organised history of previous run results are kept, you can compare a failed result easily against a previous successful run.

## Installation

Install WebInject. (refer to https://github.com/Qarj/WebInject)

From a command prompt:
```
cpan Config::Tiny
```
