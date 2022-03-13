# filter.js unit tests

## One time setup

Install nodejs, karma, karma-qunit and qunitjs

-   Install Node.js: [Node.js](https://nodejs.org/en/)

Now open a new command prompt with the updated environment variables.

In an organisation with SSL interception, you may need to:

-   `npm config set strict-ssl false`
-   `npm cache verify`

-   Install karma `npm install -g karma`
-   Install qunit-qunit `npm install -g karma-qunit`
-   Install qunit `npm install -g qunitjs`

Now change to the folder where karma.conf.js resides, then:

-   `start karma start` (on Windows)
-   `karma run`

You can create your own JavaScript unit test config by changing directory to your project, then:

-   `karma init`

Which will create `karma.conf.js` (after you answer questions about your desired setup).
