$(document).ready(function() {

    updateGroups(); //Reads the groups (Tribes) which are in format TribeName-OtherText_<somenumber>, then adds a filter for them
    makeSupersededGrey();

    var $batches = $("#results > ul > div.article > li > a.result");
    var $buttons = $(".btn").on("click", function() {

        var active = $buttons.removeClass("active")
                     .filter(this)
                     .addClass("active")
                     .data("filter");

        $batches
         .hide()
         .filter( "." + active )
         .fadeIn(450);

    });
	
	var queryfilter = getParameterByName('filter');
	if (queryfilter) {
   		$("#live-filter").val(queryfilter);
        updateFilter(queryfilter);
    }

    $("#live-filter").keyup(function(){
 
        // Retrieve the input field text
        var filter = $(this).val();

        updateFilter(filter);
 
    });

    function updateFilter(filter) {
        // Loop through the article list
        $(".row").each(function(){
 
            // If the list item does not contain the text phrase fade it out
            if ($(this).text().search(new RegExp(filter, "i")) < 0) {
                $(this).fadeOut();
 
            // Show the list item if the phrase matches
            } else {
                $(this).show();
            }
        });
    }

});

function submitFilter() {
    var url = location.protocol + '//' + location.host + location.pathname;
    var filter = $('#live-filter').val();
    var urlFilter = url;
    if (filter) {
        urlFilter = urlFilter.concat('?filter=' + filter);
    }
    window.location = urlFilter;
    return false;
}

function getParameterByName(name, url) { //http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function updateGroups() {
    insertGroups(document);
}

function insertGroups(doc) {
    var nodes = doc.querySelectorAll("a"); // The link text for the automation test result
    var nodesText = [];
    for (var i = 0; i < nodes.length; i++) {
        nodesText.push(nodes[i].textContent);
    }

    var groups = findGroups(nodesText); // Find the unique groups (Tribes)

    // Add a class for the group name to the link
    for (var i = 0; i < nodes.length; i++) {
        var matchGroup = matchesGroups(groups, nodes[i].textContent);
        if ( matchGroup ) {
            var existingClass = nodes[i].getAttribute("class");
            nodes[i].setAttribute("class", existingClass + " " + matchGroup);
            //console.log("Set class to " + existingClass + " " + matchGroup);
        }
    }

    // Now add buttons for the groups
    var groupsDiv = doc.getElementById("groups");
    for (var i = 0; i < groups.length; i++) {
        var button = doc.createElement("button");
        var passes = countRegressionPasses(groups[i], nodesText);
        var total = countRegressions(groups[i], nodesText);
        var node = doc.createTextNode(groups[i] + " " + passes + "/" + total );
        button.appendChild(node);
        if (passes === 0) {
            button.setAttribute("class", "btn red");
        } else if (passes < total){
            button.setAttribute("class", "btn orange");
        } else {
            button.setAttribute("class", "btn green");
        }
        button.setAttribute("data-filter", groups[i]);
        groupsDiv.appendChild(button);
        //console.log(groups[i]);
    }
}

function countRegressionPasses(group, list) {
    // first build up the regressions for the group    
    var regEx = new RegExp(" " + group + '-([^ ]+)_\\d+: ');  // need an additional escape for \ in this form

    var regressions = [];

    for (var i = 0; i < list.length; i++) {
        var match = regEx.exec(list[i]);
        if (match !== null) {
            regressions.push(_get_run_results(match[1], i, list));
        } else {
        }
    }

    regressions.sort( sort_by('batchTeam', {name:'start', reverse: false}) );

    var count = 0;
    var batchTeam;
    for (var i = 0; i < regressions.length; i++) {
        if (regressions[i].batchTeam !== batchTeam) {
            batchTeam = regressions[i].batchTeam;
            if (i > 0) {
                if (regressions[i-1].pass) {
                    count += 1;
                }
            }
        }
    }
    // Don't forget last batchTeam
    if (i > 0) {
        if (regressions[i-1].pass) {
            count += 1;
        }
    }

    return count;
}

function _get_run_results(name, i, list) {

    var _debug = name + " ";
    
    // first find out if it was a PASS, or not (not PASS = FAIL e.g. PEND, ABORTED, whatever)
    var passRegEx = new RegExp("(PASS )");
    var pass = 0;
    var passMatch = passRegEx.exec(list[i]);
    if (passMatch !== null) {
        pass = 1;
    }
    if (pass > 0) {
        _debug += "Passed ";
    } else {
        _debug += "Failed ";
    }
    
    // find the team / target server
    var teamRegEx = new RegExp(" mins[ ]+\\*([^*]+)\\*");
    var team = "noteam";
    var teamMatch = teamRegEx.exec(list[i]);
    if (teamMatch !== null) {
        team = teamMatch[1];
    }
    _debug += team + " ";

    // now find the start time
    var startRegEx = new RegExp(" (\\d\\d:\\d\\d:\\d\\d)[ ]+- ");
    var startStr = "";
    var start = 0;
    var startMatch = startRegEx.exec(list[i]);
    if (startMatch !== null) {
        startStr = startMatch[1];
        start = new Date('2017-01-01T'+startStr+'Z');
        _debug += startStr + " " + start;
    }

    // find the full batch name
    var fullNameRegEx = new RegExp(" ([^ ]+_\\d+): ");
    var fullName = "nofullname";
    var fullNameMatch = fullNameRegEx.exec(list[i]);
    if (fullNameMatch !== null) {
        fullName = fullNameMatch[1];
    }
    _debug += fullName + " ";

    //console.log(_debug);
    return {
        batchTeam : name+team,
        pass : pass,
        start : start.getTime(),
        fullBatchName : fullName
    }
}

function countRegressions(group, list) {
    // need an additional escape for \ in this form
    var regEx = new RegExp(" " + group + '-([^ ]+)_\\d+: ');

    var count = 0;
    var names = [];

    for (var i = 0; i < list.length; i++) {
        var match = regEx.exec(list[i]);
        if (match !== null) {
            // find the team / target server
            var teamRegEx = new RegExp(" mins[ ]+\\*([^*]+)\\*");
            var team = "noteam";
            var teamMatch = teamRegEx.exec(list[i]);
            if (teamMatch !== null) {
                team = teamMatch[1];
            }
            if (inList(names, match[1]+team)) {
                //console.log("Existing batchTeam found [" + match[1]+team + "]");
            } else {
                //console.log("New batchTeam name found [" + match[1]+team + "]");
                names.push(match[1]+team);
                count += 1;
            }
        } else {
            //console.log("Not a match for i = " + i);
        }
    }

    return count;
}

function findGroups(list) {
    var regEx = / ([a-zA-Z]+)-[^ ]+_\d+: /;

    var found = [];
    for (var i = 0; i < list.length; i++) {
        var match = regEx.exec(list[i]);
        if (match !== null) {
            //console.log(match[0]);
            if (inList(found, match[1])) {
                //console.log("Existing group found [" + match[1] + "]");
            } else {
                //console.log("New group found [" + match[1] + "]");
                found.push(match[1]);
            }
        } else {
            //console.log("Not a match for i = " + i);
        }
    }
    return found;
}

function inList(groups, group) {
    for (var i = 0; i < groups.length; i++) {
        if (groups[i] === group) {
            return true;
        }
    }
    return false;
}

function matchesGroups(groups, resultText) {
    for (var i = 0; i < groups.length; i++) {
        if ( resultText.search(groups[i]+"-") > -1 ) {
            //console.log("found a match");
            return groups[i];
        }
    }
    return "";
}
  
// https://stackoverflow.com/questions/6913512/how-to-sort-an-array-of-objects-by-multiple-fields/6913821#6913821
// homes.sort(sort_by('city', {name:'price', primer: parseInt, reverse: true}));
var sort_by;
(function() {
    // utility functions
    var default_cmp = function(a, b) {
            if (a == b) return 0;
            return a < b ? -1 : 1;
        },
        getCmpFunc = function(primer, reverse) {
            var dfc = default_cmp, // closer in scope
                cmp = default_cmp;
            if (primer) {
                cmp = function(a, b) {
                    return dfc(primer(a), primer(b));
                };
            }
            if (reverse) {
                return function(a, b) {
                    return -1 * cmp(a, b);
                };
            }
            return cmp;
        };

    // actual implementation
    sort_by = function() {
        var fields = [],
            n_fields = arguments.length,
            field, name, reverse, cmp;

        // preprocess sorting options
        for (var i = 0; i < n_fields; i++) {
            field = arguments[i];
            if (typeof field === 'string') {
                name = field;
                cmp = default_cmp;
            }
            else {
                name = field.name;
                cmp = getCmpFunc(field.primer, field.reverse);
            }
            fields.push({
                name: name,
                cmp: cmp
            });
        }

        // final comparison function
        return function(A, B) {
            var a, b, name, result;
            for (var i = 0; i < n_fields; i++) {
                result = 0;
                field = fields[i];
                name = field.name;

                result = field.cmp(A[name], B[name]);
                if (result !== 0) break;
            }
            return result;
        }
    }
}());

function makeSupersededGrey() {
    makeSupersededResultsGrey(document);
}

function makeSupersededResultsGrey(doc) {
    // get all the results
    var nodes = doc.querySelectorAll("a"); // The link text for the automation test result
    var nodesText = [];
    for (var i = 0; i < nodes.length; i++) {
        nodesText.push(nodes[i].textContent);
    }

    // find the unique batch targets    
    var regEx = new RegExp(" ([^ ]+)_\\d+: ");  // need an additional escape for \ in this form

    var regressions = [];

    for (var i = 0; i < nodesText.length; i++) {
        var match = regEx.exec(nodesText[i]);
        if (match !== null) {
            regressions.push(_get_run_results(match[1], i, nodesText));
        } else {
        }
    }

    regressions.sort( sort_by('batchTeam', {name:'start', reverse: true}) );

    // for each batchTeam, the first result is current, the rest are superseded
    var count = 0;
    var batchTeam = "";
    for (var i = 0; i < regressions.length; i++) {
        if (regressions[i].batchTeam !== batchTeam) {
            // this is the first row for that batchTeam, so it is current
            batchTeam = regressions[i].batchTeam;
        } else {
            // this result is superseded, make it grey
            makeGrey(nodes, regressions[i].fullBatchName);
        }
    }

}

function makeGrey(nodes, fullName) {
    //console.log("Making " + fullName + " grey");

    // Add a class for grey to the link
    for (var i = 0; i < nodes.length; i++) {
        if ( nodes[i].textContent.indexOf(fullName) > -1 ) {
            var existingClass = nodes[i].getAttribute("class");
            nodes[i].setAttribute("class", existingClass + " grey");
            //console.log("Set class to " + existingClass + " grey");
        }
    }

}