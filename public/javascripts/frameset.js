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
      if ($tz(this).text() == '[More]') {
        $tz(this).text('[Less]');
      } else {
        $tz(this).text('[More]');
      }
    });    

    // Show more cast/crew information
    div.find('a#movie_castcrew_link').click(function(e) {
      e.preventDefault();
      div.find('.movie_crew_all, .movie_crew_shortened, .movie_cast_shortened, .movie_cast_all').toggle();
      if ($tz(this).text() == '[See More Credits]') {
        $tz(this).text('[See Less Credits]');
      } else {
        $tz(this).text('[See More Credits]');
      }
    });          
    
    // Show hide movie info on hover over the links
    rating.find('a:first').hover(
      function(e) {
        // Immediately close all others
        $tz('.movie-info:visible').not(div).hide();
        div.show().data('cancelhide', true);
      },
      
      function(e) {
        div.show().data('cancelhide', false);
        div.trigger('delayedhide', {});
      }
    );
};

var $tz;
var urls = {};
var movies = {};
var ratings = {};

var processTorrentzPage = function(url) {

  // Remove some page elements
  $tz.find('div:has(> iframe), #suggestbox, .cloud, .footer, .top ul, form.search').remove();
  $tz.find('div.top').siblings('div:first').remove();
  $tz.find('div:last').remove();
  
  // Add the rating column
  $tz.find('.results > div:first').append(' | rating');
  
  // Clone the rating cell and append it to each row in the "table"
  var missing_ratings = [];
  var mother = $('<span class="a rating" style="width: 50px;">N/A</span>');
  $tz.find('.results dl dd').width('325px').each(function() {
    var dd = $(this);

    // Get the movie's hash and title from the movie link
    var link = dd.prev('dt').find('a');
    var hash = link.attr('href').replace(
        new RegExp('^'+RegExp.escape('http://torrentz.com/')+'(.*)$'), '$1');
    
    // If the movie is cached, use it        
    if (movies[hash] != undefined) {
      movies[hash]['rating_span'].appendTo(dd);
    } else {
      
      // Create a new movie information hash in the movie array
      var clone = mother.clone().data('tz_hash', hash).appendTo(dd);
      movies[hash] = { 
        rating_span: clone, 
        tz_title: link.text(),
        tz_hash: hash 
      };
      
      // We will need to load the rating for this movie
      missing_ratings.push(hash);
    }
  });
  
  // Load the ratings we are missing
  if (missing_ratings.length > 0) {
    loadMissingRatings(missing_ratings);  
  }
  
  // Create some live event handlers to handle actions on the links
  $tz.find('span.rating a:first')
  .live('hover', function(e) {
    alert('hover');
    // Immediately close all others
    //$tz('.movie-info:visible').not(div).hide();
    //div.show().data('cancelhide', true);
  })
  .live('blur',  function(e) {
    alert('blur');
    //div.show().data('cancelhide', false);
    //div.trigger('delayedhide', {});
  });
  
  //alert(movies.length);
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
};

var loadMissingRatings = function(missing_ratings) {
  alert('Loading ' + missing_ratings.length + ' ratings.');
  
  var data = jQuery.map(missing_ratings, function(hash) {
    return 'tz_hash[]=' + encodeURI(hash);
  }).join('&');
  
  jQuery.ajax({
    url: '/movies/ratings',
		data: data,
		dataType: 'json',
		type: 'get',
		success: function(data) {
		  
		  // *data* is an array of hashes containing movie information
		  jQuery.each(data, function(idx, movie) {
		    jQuery.extend(movies[movie['tz_hash']], movie);
		    
		    // Only show the rating if it's > 0 otherwise it couldn't be found
		    if (movie['rt_rating'] > 0) {
		      movies[movie['tz_hash']]['rating_span'].html(
		          '<a href="' + movie['path'] + '" onclick="javascript: return false;">' 
		          + movie['rt_rating'] + '%</a>');
		    }
		  });
		  
		  // Now figure out which ratings we still need to load
		  missing_ratings = jQuery.grep(missing_ratings, function(hash) {
		    if (movies[hash]['rt_rating'] == undefined) return true;
		  });
		  
		  if (missing_ratings.length > 0) {
		    alert('There are still ' + missing_ratings.length + ' ratings to load.  Retrying.');
		    setTimeout('loadMissingRatings(missing_ratings)', 3000);
		  }
    }
	});
}
