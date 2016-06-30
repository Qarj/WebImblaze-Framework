    $(document).ready(function() {

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
