window.loadFirebugConsole();

/**
 * Globals.
 *
 * *movies* holds all the information about movies, keyed by hash.
 */
var movies = {};


var TorrentzPage = function() {
  var self = this;
  
  self.movieInfoDiv = undefined;
  self.ratingLinkTemplate = $('<span class="a rating" style="width: 50px;">N/A</span>');
  
  self.init = function(window) {
    self.$ = $(window.document);
    self.processPage();
    self.createMovieInformationDiv();
    return self;
  }

  self.processPage = function() {

    // Remove some page elements
    self.$.find('div:has(> iframe), #suggestbox, .cloud, .footer, .top, form.search').remove();
    self.$.find('div:last').remove();
    self.$.find('div.results').prev('div').remove();
    
    // Add the rating column
    self.$.find('.results > div:first').append(' | rating');
  
    // Clone the rating cell and append it to each row in the "table"
    var missing_ratings = [];
    self.$.find('.results dl dd').width('325px').each(function() {
      var dd = $(this);

      // Get the movie's hash and title from the movie link 
      var link = dd.prev('dt').find('a');
      var hash = link.attr('href').replace(
          new RegExp('^'+RegExp.escape('http://torrentz.com/')+'(.*)$'), '$1');

      // Ensure that we have an entry in the movies array for this movie
      if (movies[hash] == undefined) {
        movies[hash] = {
          tz_title: link.text(),
          tz_hash: hash 
        };
      }
      
      // Create the rating link, or mark it for loading
      self.createRatingLink(hash, dd);
      if (movies[hash]['rt_rating'] == undefined) {
        missing_ratings.push(hash);
      }
    });
  
    // Load the ratings we are missing
    if (missing_ratings.length > 0) {
      self.loadMissingRatings(missing_ratings, 3000);  
    }
 
    return self;
  }

  /**
   * Create the div that will show movie information, and bind event
   * handlers to it.
   */
  self.createMovieInformationDiv = function() {
  
    var div = $('<div class="movie-info-container" style="display: none;"></div>').appendTo(self.$.find('body'));
    self.movieInfoDiv = div;
  
    // Bind mouse over handlers to the div so we can prevent it
    // from being hidden when the mouse is over it
    div.hover(
      function(e) { div.data('cancelhide', true); },
      function(e) { div.trigger('hide'); }
    );
  
    // Event to hide with a second delay
    div.bind('hide', {}, function(e) {
      div.data('cancelhide', false);
      
      div.delay(1500, function() {
        if (!div.data('cancelhide')) {
          div.slideUp('normal')
        }
      });
    });

    // Event to show a movie
    div.bind('show', {}, function(e, hash) {
      
      var div = $(this);
      var loading = div.hasClass('loading-movie');
      
      // Cancel hiding the div
      div.data('cancelhide', true);
      
      // Already showing this movie, don't do anything
      if (div.data('showing') == hash && !loading && div.is(':visible')) return; 

      // Movie not yet loaded, show loading
      div.data('showing', hash);
      if (movies[hash]['html'] == undefined) {
        
        div.addClass('loading-movie')
            .html('<div class="loading">Loading movie info...</div>')
            .slideDown('normal');
            
        // Load the movie and re-trigger this event
        self.loadMovie(hash, function() {
          div.trigger('show', hash);
        }); 
      
      // We have the movie, show it  
      } else {
        
        // We are no longer "loading"
        if (loading) {
          div.removeClass('loading-movie');
        }
        div.html(movies[hash]['html']).slideDown('normal');
      }
      
    });
      
    // Use event delegation to capture clicks on the rottentomatoes links.
    div.click(function(e) {
      e.preventDefault();
      var link = $(e.originalTarget);
      
      // Show more synopsis
      if (link.is('a#movie_synopsis_link')) {
        div.find('#movie_synopsis_all, #movie_synopsis_blurb').toggle();
        if (link.text() == '[More]') {
          link.text('[Less]');
        } else {
          link.text('[More]');
        }
      }    

      // Show more cast/crew information
      if (link.is('a#movie_castcrew_link')) {
        div.find('.movie_crew_all, .movie_crew_shortened, .movie_cast_shortened, .movie_cast_all').toggle();
        if (link.text() == '[See More Credits]') {
          link.text('[See Less Credits]');
        } else {
          link.text('[See More Credits]');
        }
      }
    });
    
    return self;
  }

  /**
   * Bind event handlers to the rating links to show/hide the movie
   * information div on hover/blur.
   */
  self.bindEventHandlers = function(hash) {
    rating_span = movies[hash]['rating_span'];
    rating_span.find('a.rating_link').hover(
      function() { self.movieInfoDiv.trigger('show', hash); },
      function() { self.movieInfoDiv.trigger('hide'); }
    );
    return self;
  };

  /**
   * Load a movie's html and store it in the global array.
   */
  self.loadMovie = function(hash, callback) {
    var movie = movies[hash];
    jQuery.get(movie['path'],
  		function(data) {
  		  
  		  // Process the movie info a bit.  Remove all the links.
  		  var html = $(data);
  		  html.find('a:not(#movie_synopsis_link, #movie_castcrew_link, #movie_tz_link, #movie_rt_link)').attr('href', '');
        movie['html'] = html.outerHTML();
        
        callback(html);
      }
    );
    return self;
  };

  /**
   * Load the missing ratings.  This recurses until we have all the ratings.
   *
   * @param missing_ratings a list of movie hashes
   */
  self.loadMissingRatings = function(missing_ratings, retry_millis) {
  
    var data = jQuery.map(missing_ratings, function(hash) {
      return 'tz_hash[]=' + encodeURI(hash);
    }).join('&');
  
    jQuery.ajax({
      url: '/movies/ratings',
  		data: data,
  		dataType: 'json',
  		type: 'get',
  		success: (function() { 
  		  return function(data) { self.processRatingsCallback(missing_ratings, data, retry_millis); } 
  		})()
  	});
  	return self;
  }
  
  /**
   * Create the rating link based on the rt_rating stored in the movies
   * array and bind event handlers to it.
   *
   * @return the new rating span element
   */
  self.createRatingLink = function(hash, append_to) {
    var span = self.ratingLinkTemplate.clone().attr('id', 'movie-' + hash);
    
    // Create the rating link, or mark it for loading
    if (movies[hash]['rt_rating'] != undefined && movies[hash]['rt_rating'] > 0) {
      
      var movie = movies[hash];
      var ratingclass = movie['rt_rating'] > 50 ? 'rating-fresh' : 'rating-rotten';

      span.html(
          '<a class="rating_link ' + ratingclass + '" href="' 
          + movie['path'] + '" onclick="javascript: return false;">' 
          + movie['rt_rating'] + '%</a>');

      // Bind hover/blur handlers to show/hide movie info
      span.find('a.rating_link').hover(
        function() { self.movieInfoDiv.trigger('show', hash); },
        function() { self.movieInfoDiv.trigger('hide'); }
      );
    }

    // Insert/update the rating in the DOM
    if (append_to != undefined) {
      span.appendTo(append_to);
    } else {
      var existingSpan = self.$.find('#movie-' + hash);
      existingSpan.replaceWith(span);
    }
      
    return span;
  }
  
  /**
   * Process an array of objects containing various movie information,
   * including ratings.
   *
   * *missing_ratings* contains the ratings that we requested
   * *data* contains the results of the ajax call
   */
  self.processRatingsCallback = function(missing_ratings, data, retry_millis) {
    if (data.length > 0) {
  	  jQuery.each(data, function(idx, movie) {
  	    jQuery.extend(movies[movie['tz_hash']], movie);
    
  	    // Only show the rating if it's > 0 otherwise it couldn't be found
  	    if (movie['rt_rating'] > 0) {
  	      self.createRatingLink(movie['tz_hash']);
  	    }
  	  });
  
  	  // Now figure out which ratings we still need to load
  	  missing_ratings = jQuery.grep(missing_ratings, function(hash) {
  	    if (movies[hash]['rt_rating'] == undefined) return true;
  	  });
  	  
    // Increase the check interval
    } else {
      retry_millis = retry_millis * 1.5;
    }
    
    // Recursively call loadMissingRatings() till we have all the ratings.
	  if (missing_ratings.length > 0) {
	    console.log('There are still ' + missing_ratings.length + ' ratings to load.  Retrying.');
	    setTimeout((function() { return function() { self.loadMissingRatings(missing_ratings, retry_millis); } })(), 3000);
	  }
  }
  
  return self;
};