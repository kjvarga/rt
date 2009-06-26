
function doIt() {
  alert('called do it!');
}

/**
 * Create a fixed-centered div containing this movie's information.
 * Also binds handlers for show/hide.
 */
var createMovieInformationDiv = function(rating, info) {
    // Format the rating
    var percent = info['rating'];
    if (percent != 'N/A') {
      percent += '%';
    }
    rating.html('<a>' + percent + '</a>');
    
    // Append movie info div
    rating.append('<div class="movie-info" style="display: none;">' 
        + '<h1>' + info['rttitle'] + '</h1>'
        + '<img src="' + info['img'] + '" />'
        + info['infobox'] + '</div>');
    var div = rating.find('> div:first');

    // Position it
    div.center();
    
    // Bind mouse over handlers to the div so we can prevent it
    // from being hidden when the mouse is over it
    div.hover(
      function(e) {
        div.data('cancelhide', true);
      },
    
      function(e) {
        div.data('cancelhide', false);
        div.trigger('delayedhide');
      }
    );
    
    // Hide with a second delay
    div.bind('delayedhide', {}, function(e) {
      div.delay(1000, function() {
          if (!div.data('cancelhide')) {
            div.hide();
          }
      });
    });
    
    // Show more synopsis
    div.find('a#movie_synopsis_link').click(function(e) {
      e.preventDefault();
      div.find('#movie_synopsis_all, #movie_synopsis_blurb').toggle();
      if ($(this).text() == '[More]') {
        $(this).text('[Less]');
      } else {
        $(this).text('[More]');
      }
    });    

    // Show more cast/crew information
    div.find('a#movie_castcrew_link').click(function(e) {
      e.preventDefault();
      div.find('.movie_crew_all, .movie_crew_shortened, .movie_cast_shortened, .movie_cast_all').toggle();
      if ($(this).text() == '[See More Credits]') {
        $(this).text('[See Less Credits]');
      } else {
        $(this).text('[See More Credits]');
      }
    });          
    
    // Show hide movie info on hover over the links
    rating.find('a:first').hover(
      function(e) {
        // Immediately close all others
        $('.movie-info:visible').not(div).hide();
        div.show().data('cancelhide', true);
      },
      
      function(e) {
        div.show().data('cancelhide', false);
        div.trigger('delayedhide', {});
      }
    );
};

var ratings = [];

var processTorrentzPage = function() {

  // Remove some page elements
  $('div:has(> iframe), .cloud, .footer, .top ul, form.search').remove();
  
  // Add the refresh information
  /*var reload_millis = lastCached + (5 * 60 * 1000);  // Add 5 minutes
  var diff = (reload_millis - (new Date()).getTime()) / 1000;  // Convert to seconds
  var minutes = Math.floor(Math.abs(diff) / 60);
  var seconds = Math.round(Math.abs(diff) % 60);*/
  
  /*$('.top').after('<div id="refresh">Cache refresh in '+minutes+' minutes '+seconds+' seconds.'
      + '  Page loads will be slow while caching movie information.</div>'); 
  $('.top').next().css('margin', '5px 0 0 10px');*/
  
  // Add the rating column
  $('.results > div:first').append(' | rating').append(' | buy');
  
  // Clone the rating cell and append it to each row in the "table"
  var mother = $('<span class="a rating" style="width: 50px;">N/A</span>');
  $('.results dl dd').width('325px').each(function() {
    var dd = $(this);
    
    // Get the movie's hash and title from the movie link
    // and store it as data on the cloned rating 
    var link = dd.prev('dt').find('a');
    var hash = link.attr('href').replace(
        new RegExp('^'+RegExp.escape('/')+'(.*)$'), '$1');
    var clone = mother.clone().data('hash', hash).data('title', link.text()).appendTo(dd);
    
    // Store it in the list
    ratings.push(clone);
  });
  
  // Go through the movies and add movie information divs for all
  // the loaded movies
  /*jQuery.each(movies, function(hash, info) {
    if (!info['loaded']) {
      return true; // continue
    }
    
    // Find the rating element that belongs to this movie.
    // Match them by their hash.
    jQuery.each(ratings, function(idx, rating) {
      if (rating.data('hash') != info['hash']) {
        return true; // continue
      }
      
      createMovieInformationDiv(rating, info);
      return false;
    });
  });*/
});

