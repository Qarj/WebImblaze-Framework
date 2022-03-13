# filter.js unit tests

## One time setup

```
npm install
```

In an organisation with SSL interception, you may need to:

-   `npm config set strict-ssl false`
-   `npm cache verify`

# Run the tests

```
npm test
```

# Run via Karma

Change to the folder where karma.conf.js resides, then:

-   `start karma start` (on Windows)
-   `karma run`

For CI:

-   `karma start --single-run`

# Setting up a Karma project

You can create your own JavaScript unit test config by changing directory to your project, then:

-   `karma init`

Which will create `karma.conf.js` (after you answer questions about your desired setup).
