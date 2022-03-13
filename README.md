# WebImblaze-Framework 1.13.2

[![GitHub Super-Linter](https://github.com/Qarj/WebImblaze-Framework/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
![Canary test](https://github.com/Qarj/WebImblaze-Framework/workflows/Self%20test/badge.svg)

Automated regression testing framework for

-   managing WebImblaze configuration
-   running many WebImblaze automated tests in parallel
-   organising actual test run results for many teams and test case files

This framework is for those with large suites of automated tests. It helps to quickly
answer the question "Did all of our regression tests pass?".

If the answer is no, you can very quickly drill into what went wrong.
Since an organised history of previous run results are kept,
you can compare a failed result easily against a previous successful run.

You can see WebImblaze example output here: [WebImblaze-Example](http://qarj.github.io/WebInject-Example/)

## Quick Start Guide - 5 minutes to install and use

### Linux

After installing [WebImblaze](https://github.com/Qarj/WebImblaze) to `$HOME/git/WebImblaze`, clone companion project

```sh
cd $HOME/git
git clone https://github.com/Qarj/WebImblaze-Framework.git
```

Open a terminal then install gnome-terminal and Apache.

```sh
sudo apt update
sudo apt --yes install gnome-terminal
sudo apt --yes install apache2
sudo apt --yes install apache2-dev
```

Restart Apache and make sure there are no error messages.

```sh
sudo systemctl restart apache2
```

Fix permissions for Apache.

```sh
sudo chgrp -R www-data /var/www/html
sudo find /var/www/html -type d -exec chmod g+rwx {} +
sudo find /var/www/html -type d -exec chmod a+rwx {} +
sudo find /var/www/html -type f -exec chmod g+rw {} +
```

Install Perl packages required by `wif.pl`.

```sh
cpan Config::Tiny
cpan File::Find::Rule
cpan File::Slurp
```

Create `wif.config`.

```sh
cd $HOME/git/WebImblaze-Framework
perl wif.pl --create-config
```

Optional - edit the config file, and change the `web_server_address` parameter from `localhost` to the DNS name of the server.

```sh
nano wif.config
```

If you don't do this, you won't be able to access the results from outside this server.

Confirm that you can view the help without error messages.

```sh
perl wif.pl --help
```

Run the canary checks too.

```sh
perl wif.pl canary/canary.test
```

### Windows Installation

Install WebImblaze. Refer to [WebImblaze](https://github.com/Qarj/WebImblaze).

Clone the project.

```bat
cd /D C:/git
git clone https://github.com/Qarj/WebImblaze-Framework.git
```

Install Perl packages required by `wif.pl`.

```bat
cpan Config::Tiny
```

Now install Apache for Windows.

First ensure that IIS isn't installed and running.
Press the Windows key and type `Turn Windows` then select the menu item `Turn Windows Features on or Off`.
Ensure `Internet Information Services` (IIS) is turned off. (On Windows 10 it is turned off by default).

From Apache Lounge [Apache Lounge](https://www.apachelounge.com/download/) download Win32 zip file - not 64 bit, then extract so C:\Apache24\bin folder is available.

Administrator Command Prompt

```bat
curl -o %temp%/Apache24.zip https://home.apache.org/~steffenal/VC15/binaries/httpd-2.4.37-win32-VC15.zip
"C:\Program Files\7-Zip\7z.exe" x %temp%/Apache24.zip -o"C:\" -r -x!ReadMe.txt -x!"-- Win32 VC15  --"
```

Then open a command prompt as Administrator.

```bat
cd C:/Apache24/bin
httpd -k install
httpd -k start
```

If `httpd` does not work, the Visual Studio redist might be needed

```bat
curl -o %temp%/VC_redist.x86.exe https://aka.ms/vs/15/release/VC_redist.x86.exe
%temp%\VC_redist.x86.exe
```

May also need to set your server name in `http.conf` to stop 10 second delays, refer to [Why slow](https://serverfault.com/questions/66347/why-is-the-response-on-localhost-so-slow)

```txt
ServerName my.server.com:80
```

Now create the `wif.config` file.

```bat
cd /D C:/git/WebImblaze-Framework
perl wif.pl --create-config
```

You don't need to change the default settings for this example to work.

Find out the DNS name of this server.

```bat
echo %COMPUTERNAME%.%USERDNSDOMAIN%
```

Edit the config file, and change the `web_server_address` parameter from `localhost` to the DNS name of the server.

```bat
notepad wif.config
```

If you don't do this, you won't be able to access the results from outside this server.

That's it! You are now ready to run your first WebImblaze test using the WebImblaze Framework.

### running wif.pl - minimal example

To run an automated test, wif.pl needs to know the:

-   test file to run
-   high level environment
-   target 'mini-environment' - team name (has own web server, but sharing a development database with other teams)

```sh
perl wif.pl example_test --env DEV --target team1
```

If everything worked ok, wif.pl created a configuration file for WebImblaze, called
WebImblaze, ran the tests, then put all the results in your web server location.

You can view the results by going to [Batch Summary](http://localhost/DEV/Summary.xml)

Since wif.pl will remember the last test file you ran, and environment details, you
can run it again as follows:

```sh
perl wif.pl
```

If you want to run another example, since the environment details have not changed,
you can just specify the test case file:

```sh
perl wif.pl ../WebImblaze/examples/advanced/hello
```

The WebImblaze framework will search for the test case file that is the best match and run it.

```sh
perl wif.pl examples/hello
```

Will also work, and even

```sh
perl wif.pl hello
```

Finally, run another example, but store the result under a batch name:

```sh
perl wif.pl examples/post.xml --batch my_team_results
```

### Viewing the test run results

You can view and drill into the results from this url:

[http://localhost/DEV/Summary.xml](http://localhost/DEV/Summary.xml)

Click on a batch to see individual test results for the batch.

Click on the Run number (first column) to see the individual step results for a test case file.

From the test case file results, click on the ID number (first column), to see that step actual result.

## Running tests in parallel

The point of the WebImblaze-Framework is to run a lot of tests quickly and check that there are no failures.

To see this in action, go and first install the Selenium plugin for WebImblaze [WebImblaze-Selenium](https://github.com/Qarj/WebImblaze-Selenium)

Now run the all of the WebImblaze examples

```sh
perl tasks/Examples.pl
```

You'll see a lot of command prompts open, run some tests then close, all at the same time.

Note that when you view the results at [Result Summary](http://localhost/DEV/Summary.xml)
you'll see a lot of errors. Many of the examples show how various assertions work, and how tests can be automatically
retried on failure.

In practice, the tests should be run by a service account. You can use Windows Task Scheduler to run the tests overnight.

You can run all the WebImblaze self tests quickly as follows:

```sh
perl tasks/Selftest.pl
```

Note that the tasks\ scripts can take parameters too

```sh
perl tasks/Examples.pl --env DEV --target team2 --batch My_Examples
```

### Pending results

While the tests are running, you can see intermediate results. Just go the results Summary page, click
on the batch, and see the pending results. You can press F5 as results complete to see the latest
completions.

On a pending result, you can click on the Started date/time for a test file and see where it is up to. Again
just press F5 to get the latest update.

## Syntax Hightlighting - Visual Studio Code

Search extensions for `WebImblaze` then install `WebImblaze Syntax Highlighting`.

## Syntax Highlighting - Notepad++

Syntax Highlights of WebImblaze `.test` files works will with Material-Dark theme and Monaco font.

Download Material-Dark

```bat
curl -o C:\git\WebImblaze-Framework\tools\Material-Dark.xml https://raw.githubusercontent.com/naderi/material-theme-for-npp/master/Material-Dark.xml
```

Copy Material-Dark to `%APPDATA%\Notepad++\themes`

```bat
copy C:\git\WebImblaze-Framework\tools\Material-Dark.xml "%APPDATA%\Notepad++\themes"
```

Or on Linux, assuming Notepad++ is installed in a wine bottle of `/home/$USER/wine/wine64`

```sh
curl -o /home/$USER/wine/wine64/drive_c/users/$USER/AppData/Roaming/Notepad++/themes/Material-Dark.xml https://raw.githubusercontent.com/naderi/material-theme-for-npp/master/Material-Dark.xml
```

Download Monaco font

```bat
curl -o C:\git\WebImblaze-Framework\tools\monaco.ttf https://raw.githubusercontent.com/todylu/monaco.ttf/master/monaco.ttf
```

Right click on `tools/monaco.ttf` in Windows Explorer and click `Install`.

From `Language` menu, select `Define your language...`
Click `Import...`
Copy paste this to the filename `C:\git\WebImblaze-Framework\tools\webimblaze_notepad++.xml`

Restart Notepad++

From `Settings` menu, select `Style Configurator...`
Select theme: `Material-Dark`
Click `Enable global background colour`
Save and close

## Markdown highlighting

```bat
curl -o C:\git\WebImblaze-Framework\tools\Zenburn-Markdown.xml https://raw.githubusercontent.com/Edditoria/markdown-plus-plus/master/theme-zenburn/userDefinedLang-markdown.zenburn.modern.xml
```

Then import the language.

## The WebImblaze Framework Manual

The manual contains full details on how to setup WebImblaze Framework.

[WebImblaze Framework Manual - MANUAL.md](MANUAL.md)
