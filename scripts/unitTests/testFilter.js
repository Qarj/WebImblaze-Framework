//  These unit tests check the funcitonality on the Summary.XML page that adds buttons for batch names in the form of
//
//      GroupName-Core_Regression_89349
//
//  GroupName will be interpreted as a group, and a button added to filter on them
//
//  The number at the end, 89349 is a randomly generated number from Runner.pm that the tasks/regression.pl task runner files use

//start karma start
//karma run

// Custom assertion for comparing floating point numbers
QUnit.assert.near = function( actual, expected, message, error ) {
    if (error === void 0 || error === null) {
        error = 0.00000001;
    }

    var result = false;
    if (actual <= expected + error && actual >= expected - error) {
        result = true;
    }
    
    this.pushResult( {
        result: result,
        actual: actual,
        expected: expected,
        message: message
    } );
};

QUnit.test( "near", function( assert ) {
    assert.expect( 2 );

    assert.near( 6, 5, "6 is near enough to 5 (error up to 2)", 2 );
    assert.near( 1.00000001, 1, "1.00000001 is near enough to 1 (default error)" );
});

QUnit.test('Check that Unit Test Framework is up and running', function(assert) {
    // Setup the various states of the code you want to test and assert conditions.
    assert.equal(1, 1, '1 === 1');  // actual, expected, message
    assert.ok(true, 'true is truthy');
    assert.ok(1, '1 is also truthy');
    assert.ok([], 'so is an empty array or object');
});

QUnit.test('Should return an empty list', function(assert) {
    var results = ["[1 item] Eternity_Looper_3234: ALL"]; // - is the delimiter for an end of group name
    var groups = findGroups(results);
    assert.equal(groups.length, 0, 'Should have a zero length, not ' + groups.length);
});

QUnit.test('Should return a list containing Eternity', function(assert) {
    var results = ["[1 item] Eternity-Looper_3234: ALL"];
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
});

QUnit.test('Should return a list containing Enterprise', function(assert) {
    var results = ["[2 items] Enterprise-Super_3234: ALL"];
    var groups = findGroups(results);
    var expected = "Enterprise";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
});

QUnit.test('Should return a list containing only Eternity', function(assert) {
    var results = ["[1 item] Fraternity_Looper_3234: ALL"];
    results.push("[1 item] Eternity-Looper_3234: ALL");
    results.push("[1 item] NowNow_Looper_3234: ALL");
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
    assert.equal(groups.length, 1, 'Should have only 1 item in the list, not ' + groups.length);
});

QUnit.test('Should return a list containing only Eternity, multiple matches the same count as 1', function(assert) {
    var results = ["[1 item] Eternity-Looper_1134: ALL"];
    results.push("[1 item] Eternity-Looper_5234: ALL");
    results.push("[1 item] Eternity-Looper_1234: ALL");
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
    assert.equal(groups.length, 1, 'Should have only 1 item in the list, not ' + groups.length);
});

QUnit.test('Should return a list containing Eternity and Enterprise, multiple matches the same count as 1', function(assert) {
    var results = ["[1 item] Eternity-Looper_1134: ALL"];
    results.push("[1 item] Eternity-Looper_5234: ALL");
    results.push("[5 items] Enterprise-Looper_5234: ALL");
    results.push("[1 item] Enterprise-Looper_7234: ALL");
    results.push("[1 item] Eternity-Looper_2234: ALL");
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
    expected = "Enterprise";
    assert.ok(inList(groups, expected), expected + ' should be returned in list [' + groups +']');
    assert.equal(groups.length, 2, 'Should have only 1 item in the list, not ' + groups.length);
});

function createResultsDocument() {
    var doc = document.implementation.createHTMLDocument("Unittest filter");
    
        var filterDiv = doc.createElement("div");
        filterDiv.setAttribute("id", "filter");

            var button = doc.createElement("button");
            button.setAttribute("class", "btn active");
            button.setAttribute("data-filter", "result");
            var buttonText = doc.createTextNode("Show All");
            button.appendChild(buttonText);

            var span = doc.createElement("span");
            span.setAttribute("id", "groups");

        filterDiv.appendChild(button);
        filterDiv.appendChild(span);

        var resultsDiv = doc.createElement("div");
        resultsDiv.setAttribute("id", "results");

            var uList = doc.createElement("ul");
            
                var articleDiv = doc.createElement("div");
                articleDiv.setAttribute("class", "article");

                    var list = doc.createElement("li");
                    list.setAttribute("class", "row");
                        
                        var a = doc.createElement("a");
                        a.setAttribute("class", "result pass");
                        a.setAttribute("href", "http://localhost/DEV/2017/11/25/All%20Batches/ManualRun.xml");
                        a.setAttribute("rel", "bookmark");
                        a.setAttribute("style", "display: inline;");
                        var textNode = doc.createTextNode("PASS 25/11 16:14:01  - 16:15:01 [1 item] ManualRun: ALL 2 steps OK, 0.0 mins  *webinject_examples*");
                        a.appendChild(textNode);
                    
                    list.appendChild(a);
                    
                articleDiv.appendChild(list);
            
            uList.appendChild(articleDiv);
        
        resultsDiv.appendChild(uList);

    doc.body.appendChild(filterDiv);
    doc.body.appendChild(resultsDiv);
    
    return doc;
}

function addResult(doc, batchName, runResult, startTime, teamName) {
    if (typeof runResult === 'undefined') { runResult = 'PASS'; }
    if (typeof startTime === 'undefined') { startTime = '16:15:59'; }
    if (typeof teamName === 'undefined') { teamName = 'webinject_examples'; }

    var uList = doc.getElementById("results").firstChild;

        var articleDiv = doc.createElement("div");
        articleDiv.setAttribute("class", "article");

            var list = doc.createElement("li");
            list.setAttribute("class", "row");
                
                var a = doc.createElement("a");
                a.setAttribute("class", "result pass");
                a.setAttribute("href", "http://localhost/DEV/2017/11/25/All%20Batches/" + batchName + ".xml");
                a.setAttribute("rel", "bookmark");
                a.setAttribute("style", "display: inline;");
                var textNode = doc.createTextNode(runResult + " 25/11 " + startTime + "  - 16:18:02 [1 item] " + batchName + ": ALL 2 steps OK, 0.0 mins  *" + teamName + "*");
                a.appendChild(textNode);
            
            list.appendChild(a);
                    
        articleDiv.appendChild(list);
   
   uList.appendChild(articleDiv);
}

QUnit.test('Should insert a button for Eternity into the DOM', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Eternity-Regression_1234");
    //console.log(doc.documentElement.innerHTML);

    insertGroups(doc);
    //console.log(doc.documentElement.innerHTML);

    actual = doc.documentElement.innerHTML;
    assert.ok(actual.search("result pass Eternity") > -1, "Eternity should be added to class of a tag");
    assert.ok(actual.search('data-filter="Eternity">Eternity 1/1</button>') > -1, "Button should be created for Eternity");
});

QUnit.test('Eternity should be added as a class for all matching a tags', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Eternity-Regression_1111");
    addResult(doc, "Eternity-Regression_2222");
    addResult(doc, "Eternity-Regression_3333");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    assert.ok( (actual.match(/result pass Eternity/g)||[]).length === 3, "Eternity should be added to class of three a tags");
});

QUnit.test('Buttons should be added for Eternity, Enterprise, Qarj', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Eternity-Regression_1111");
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Smoke_2981");
    addResult(doc, "Qarj-Regression_8888");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    assert.ok( (actual.match(/data-filter="Eternity">Eternity/g)||[]).length === 1, "Eternity should be added as a button");
    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise/g)||[]).length === 1, "Enterprise should be added as a button");
    assert.ok( (actual.match(/data-filter="Qarj">Qarj/g)||[]).length === 1, "Qarj should be added as a button");
});

QUnit.test('Button should be not be added for XmlJobPoster - no batch number', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "XmlJobPoster-LogOnly");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    assert.ok( (actual.match(/data-filter="XmlJobPoster">XmlJobPoster/g)||[]).length === 0, "Eternity should not be added as a button, no batch number");
});

//
// Show number of unique regressions per Tribe / team
//

QUnit.test('Enterprise should have 2 regressions shown in button, Eternity 1, Qarj 1', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Eternity-Regression_1111");
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981");
    addResult(doc, "Qarj-Regression_8888");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual);

    assert.ok( (actual.match(/data-filter="Eternity">Eternity 1/g)||[]).length === 1, "Eternity should have 1 regression");
    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2/g)||[]).length === 1, "Enterprise should have 2 regressions");
    assert.ok( (actual.match(/data-filter="Qarj">Qarj 1/g)||[]).length === 1, "Qarj should have 1 regression");
});

QUnit.test('Enterprise should have 2 regressions shown in button, Eternity 1, Qarj 1 due to multiple regression of the same type', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Eternity-Regression_1111");
    addResult(doc, "Eternity-Regression_2222");
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981");
    addResult(doc, "Enterprise-Regression_8325");
    addResult(doc, "Qarj-Regression_1234");
    addResult(doc, "Qarj-Regression_4321");
    addResult(doc, "Qarj-Regression_8888");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual);

    assert.ok( (actual.match(/data-filter="Eternity">Eternity 1/g)||[]).length === 1, "Eternity should have 1 regression");
    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2/g)||[]).length === 1, "Enterprise should have 2 regressions");
    assert.ok( (actual.match(/data-filter="Qarj">Qarj 1/g)||[]).length === 1, "Qarj should have 1 regression");
});

//
// Show how many unique regressions passed per Tribe / Target
//

QUnit.test('Enterprise should have 2 out of 2 passed regressions shown in button', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual);

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2\/2/g)||[]).length === 1, "Enterprise should have 2 out 2 passed regressions");
});

QUnit.test('Enterprise should have 1 out of 2 passed regressions shown in button', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "FAIL");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual);

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 1\/2/g)||[]).length === 1, "Enterprise should have 1 out 2 passed regressions");
});


QUnit.test('Enterprise should have 2 out of 2 passed regressions shown in button - latest Regression with same name was a pass', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "FAIL", "07:30:01");
    addResult(doc, "Enterprise-Regression_1200", "PASS", "07:30:03");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual);

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2\/2/g)||[]).length === 1, "Enterprise should have 2 out 2 passed regressions since latest Regression with same batch name was a pass");
});

QUnit.test('Enterprise should have 1 out of 2 passed regressions shown in button - latest Regression with same batch name did not pass', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "PASS", "07:30:01");
    addResult(doc, "Enterprise-Regression_1200", "FAIL", "07:30:03");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 1\/2/g)||[]).length === 1, "Enterprise should have 1 out 2 passed regressions since latest Regression with same batch name did not pass");
});

QUnit.test('Enterprise should have 3 out of 3 passed regressions shown in button', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "PASS", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "PASS", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "PASS", "07:30:05", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 3\/3/g)||[]).length === 1, "Enterprise should have 3 out of 3 passed regressions");
});

QUnit.test('Enterprise should have 2 out of 3 passed regressions shown in button due to last run fail', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "PASS", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "PASS", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "FAIL", "07:30:05", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2\/3/g)||[]).length === 1, "Enterprise should have 2 out of 3 passed regressions");
});

QUnit.test('Enterprise should have 3 out of 3 passed regressions shown in button despite earlier fail', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "PASS", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "FAIL", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "PASS", "07:30:05", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 3\/3/g)||[]).length === 1, "Enterprise should have 3 out of 3 passed regressions despite fail");
});

QUnit.test('Enterprise should have 2 out of 3 passed regressions shown in button due to minerva fail', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723");
    addResult(doc, "Enterprise-Regression_2981", "FAIL", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "FAIL", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "PASS", "07:30:05", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 2\/3/g)||[]).length === 1, "Enterprise should have 2 out of 3 passed regressions due to minvera fail");
});

QUnit.test('Enterprise should have 4 out of 4 passed regressions', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723", "FAIL", "00:59:59", "minerva");
    addResult(doc, "Enterprise-Smoke_1723", "PASS", "03:01:01", "minerva");
    addResult(doc, "Enterprise-Regression_2981", "FAIL", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_2111", "PASS", "12:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "FAIL", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1222", "FAIL", "07:30:04", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "PASS", "07:30:05", "columbo");
    addResult(doc, "Enterprise-Smoke_72223", "PASS", "04:23:01", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 4\/4/g)||[]).length === 1, "Enterprise should have 4 out of 4 passed regressions");
});

QUnit.test('Enterprise should have 0 out of 4 passed regressions', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_8723", "FAIL", "18:59:59", "minerva");
    addResult(doc, "Enterprise-Smoke_8723", "PASS", "08:59:59", "minerva");
    addResult(doc, "Enterprise-Regression_2981", "FAIL", "07:30:01", "minerva");
    addResult(doc, "Enterprise-Regression_1200", "PASS", "07:30:03", "columbo");
    addResult(doc, "Enterprise-Regression_1222", "PASS", "07:30:04", "columbo");
    addResult(doc, "Enterprise-Regression_1321", "FAIL", "17:30:05", "columbo");
    addResult(doc, "Enterprise-Smoke_72223", "FAIL", "23:23:01", "columbo");
    addResult(doc, "Enterprise-Smoke_72223", "PASS", "04:23:01", "columbo");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/data-filter="Enterprise">Enterprise 0\/4/g)||[]).length === 1, "Enterprise should have 0 out of 4 passed regressions");
});

QUnit.test('Enterprise button should be green since 2/2 passed', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_1723", "PASS", "03:01:01", "minerva");
    addResult(doc, "Enterprise-Regression_2111", "PASS", "12:30:01", "minerva");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/class="btn green" data-filter="Enterprise"/g)||[]).length === 1, "Enterprise button should be green");
});

QUnit.test('Enterprise button should be orange since 1/2 passed', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_1723", "FAIL", "03:01:01", "minerva");
    addResult(doc, "Enterprise-Regression_2111", "PASS", "12:30:01", "minerva");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/class="btn orange" data-filter="Enterprise"/g)||[]).length === 1, "Enterprise button should be orange");
});

QUnit.test('Enterprise button should be red since 0/2 passed', function(assert) {

    doc = createResultsDocument();
    addResult(doc, "Enterprise-Smoke_1723", "FAIL", "03:01:01", "minerva");
    addResult(doc, "Enterprise-Regression_2111", "FAIL", "12:30:01", "minerva");

    insertGroups(doc);

    actual = doc.documentElement.innerHTML;
    //console.log(actual); 

    assert.ok( (actual.match(/class="btn red" data-filter="Enterprise"/g)||[]).length === 1, "Enterprise button should be red");
});



