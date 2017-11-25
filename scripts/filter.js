$(document).ready(function() {

    updateGroups(); //Reads the groups (Tribes) which are in format TribeName-OtherText_<somenumber>, then adds a filter for them

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
        var node = doc.createTextNode(groups[i]);
        button.appendChild(node);
        button.setAttribute("class", "btn");
        button.setAttribute("data-filter", groups[i]);
        groupsDiv.appendChild(button);
        //console.log(groups[i]);
    }
    
    return doc;
}

function findGroups(list) {
    var regEx = / ([a-zA-Z]+)-[^:]+: /;

    var found = [];
    for (var i = 0; i < list.length; i++) {
        var match = regEx.exec(list[i]);
        if (match !== null) {
            //console.log(match[0]);
            if (inGroups(found, match[1])) {
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

function inGroups(groups, group) {
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
