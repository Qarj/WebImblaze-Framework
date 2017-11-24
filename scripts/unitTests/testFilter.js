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
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
});

QUnit.test('Should return a list containing Enterprise', function(assert) {
    var results = ["[2 items] Enterprise-Super_3234: ALL"];
    var groups = findGroups(results);
    var expected = "Enterprise";
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
});

QUnit.test('Should return a list containing only Eternity', function(assert) {
    var results = ["[1 item] Fraternity_Looper_3234: ALL"];
    results.push("[1 item] Eternity-Looper_3234: ALL");
    results.push("[1 item] NowNow_Looper_3234: ALL");
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
    assert.equal(groups.length, 1, 'Should have only 1 item in the list, not ' + groups.length);
});

QUnit.test('Should return a list containing only Eternity, multiple matches the same count as 1', function(assert) {
    var results = ["[1 item] Eternity-Looper_1134: ALL"];
    results.push("[1 item] Eternity-Looper_5234: ALL");
    results.push("[1 item] Eternity-Looper_1234: ALL");
    var groups = findGroups(results);
    var expected = "Eternity";
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
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
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
    expected = "Enterprise";
    assert.ok(inGroups(groups, expected), expected + ' should be returned in list [' + groups +']');
    assert.equal(groups.length, 2, 'Should have only 1 item in the list, not ' + groups.length);
});
