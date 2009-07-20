if (window.loadFirebugConsole != undefined) {
  window.loadFirebugConsole();
} else {
  window.console = { log: function() {} };
}

/**
 * jQuery Event Hover 1.0
 * @see http://blog.threedubmedia.com/2008/08/eventspecialhover.html
 */
eval(function(p,a,c,k,e,r){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}(';(5($){$.p.S=$.p.6;$.p.6=5(a,b,c){7(c)3.o(\'B\',a);7(b)3.o(\'w\',c?c:b);L!a?3.K(\'6\'):3.o(\'6\',c?b:a)};z d=$.1.M.6={8:x,9:x,P:5(a){a=$.J({9:d.9,8:d.8,j:0},a||{});$.1.E(3,"u v",4,a)},O:5(){$.1.k(3,"u v",4)}};5 4(a){z b=a.R||a;Q(a.f){l\'u\':b.g=0;b.1=a;a.f="B";7($.1.r.s(3,a)!==y){b.h=3;$.1.E(3,"i",4,b);b.q=F(m,b.8)}e;l\'i\':b.g+=t.n(a.C-b.1.C,2)+t.n(a.A-b.1.A,2);b.1=a;e;l\'v\':N(b.q);7(b.j){a.f="w";$.1.r.s(3,a);b.j--}D $.1.k(b.h,"i",4);e;G:7(b.g<=t.n(b.9*(b.8/H),2)){$.1.k(b.h,"i",4);b.1.f="6";7($.1.r.s(b.h,b.1)!==y)b.j++}D b.q=F(m,b.8);b.g=0;e}5 m(){4(b)}}})(I);',55,55,'|event||this|hoverHandler|function|hover|if|delay|speed|||||break|type|dist2|elem|mousemove|hovered|remove|case|compare|pow|bind|fn|timer|handle|call|Math|mouseenter|mouseleave|hoverend|100|false|var|pageY|hoverstart|pageX|else|add|setTimeout|default|1e3|jQuery|extend|trigger|return|special|clearTimeout|teardown|setup|switch|data|_hover'.split('|'),0,{}))
$.fn.outerHTML = function() { return $('<div>').append( this.eq(0).clone() ).html(); }
$.fn.highlightShow = function(speed) {
  this.each(function() {
    if ($(this).hidden().length) {
      this.style.display = "none";         // highlight only works when display is none
      this.style.visibility = "visible";
    }
    var apply_to = $(this);
    if ($(this).is('tr')) {
      apply_to = apply_to.find('td');
    }
    apply_to.effect('highlight', {}, speed);
  });
  return this;
}
$.fn.hidden = function() {
  var hidden = [];
  this.each(function() {
    if (this.style.visibility == 'hidden') {
      hidden.push(this);
    }
  });
  return $(hidden);
}
$.fn.delay = function(time, callback) {
  // Empty function:
  jQuery.fx.step.delay = function(){};
  // Return meaningless animation, (will be added to queue)
  return this.animate({delay:1}, time, callback);
}
    
/**
 * Globals.
 *
 * *movies* holds all the information about movies, keyed by hash.
 */
var movies = {};
var current_page = '';

var TorrentzPage = function() {
  var self = this;
  
  self.RELOAD_MILLIS = 1500;
  self.movieInfoDiv = undefined;
  self.ratingLinkTemplate = $('<span class="a rating" style="width: 50px;">N/A</span>');
  
  self.init = function(window) {
    self.window = window;
    
    // Store the current page in a global variable so that we can
    // stop loading missing ratings when the page is changed.
    self.current_page = window.document.location.href;
    current_page = self.current_page;
    
    self.processPage();
    self.createMovieInformationDiv();
    return self;
  }

  self.processPage = function() {

    // Remove some page elements
    $('a[href^="/feed"]:first').remove();

    // Add the rating column
    $('.results > div:first').append(' | rating');
  
    // Add the ratings help bubble
    $('<div class="ratings-help"><div class="comment-arrow" />Hover over the ratings to see movie info.</div>')
        .insertBefore($('div.results:first'));
        
    // Clone the rating cell and append it to each row in the "table"
    var missing_ratings = [];
    $('.results dl dd').width('325px').each(function() {
      var dd = $(this);

      // Get the movie's hash and title from the movie link 
      var link = dd.prev('dt').find('a');
      var hash = link.attr('href').replace(
          new RegExp('^http://torrentz.com/(.*)$'), '$1');

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
      self.loadMissingRatings(missing_ratings, self.RELOAD_MILLIS);  
    }
 
    return self;
  }

  /**
   * Create the div that will show movie information, and bind event
   * handlers to it.
   */
  self.createMovieInformationDiv = function() {
  
    var div = $('<div class="movie-info-container" style="display: none;"></div>').appendTo($('body'));
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
          div.slideUp('normal');
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
            .html('<div class="loading">Loading movie</div>');
        if (!div.is(':visible')) { div.slideDown('normal'); }
            
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
        div.html(movies[hash]['html']);
        if (!div.is(':visible')) { div.slideDown('normal'); }
      }
      
    });
      
    TorrentzPage.bindHandlersToRottenTomatoesLinks(div);
    return self;
  }
  
  /**
   * Load a movie's html and store it in the global array.
   */
  self.loadMovie = function(hash, callback) {
    var movie = movies[hash];
    jQuery.get(movie['path'],
  		function(data) {
  		  
  		  // Process the movie info a bit.  Remove all the links.
  		  var html = $(data);
  		  html.find('a:not(#movie_synopsis_link, #movie_castcrew_link, #movie_tz_link, #movie_rt_link)').each(function(idx, link) {
  		    var link = $(link);
  		    link.replaceWith(link.text());
  		  });
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
  
    // Stop loading missing ratings now if the page has changed
    if (self.current_page != current_page) {
      console.log('The page has changed to ' + current_page + ' so stop loading ratings for ' + self.current_page);
      return self;
    }
    
    var data = jQuery.map(missing_ratings, function(hash) {
      return 'tz_hash[]=' + encodeURI(hash);
    }).join('&');
    data = data + '&url=' + encodeURI(self.current_page);
    
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
    
    // Create the link if the movie has been loaded
    if (movies[hash]['status'] != undefined && movies[hash]['status'] == 'loaded') {
      
      var movie = movies[hash];
      var ratingclass, rating_text;
      
      if (movies[hash]['rt_rating'] > 0) {
        ratingclass = movie['rt_rating'] > 50 ? 'rating-fresh' : 'rating-rotten';
        rating_text = movie['rt_rating'] + '%';
      } else {
        ratingClass = 'not-available';
        rating_text = 'N/A';
      }
      
      span.html(
          '<a class="rating_link ' + ratingclass + '" href="' 
          + movie['path'] + '" onclick="javascript: return false;">' 
          + rating_text + '</a>');

      // Bind hover and hoverend handlers to the rating links
      span.find('a.rating_link').bind('hover', { speed: 20, delay: 100 }, function() { self.movieInfoDiv.trigger('show', hash); });
      span.find('a.rating_link').bind('hoverend', { speed: 20, delay: 100 }, function() { self.movieInfoDiv.trigger('hide'); });
    }

    // Insert/update the rating in the DOM
    if (append_to != undefined) {
      span.appendTo(append_to);
    } else {
      var existingSpan = $('#movie-' + hash);
      existingSpan.replaceWith(span);
      //span.highlightShow();
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
        self.createRatingLink(movie['tz_hash']);
  	  });
  
  	  // Now figure out which ratings we still need to load
  	  missing_ratings = jQuery.grep(missing_ratings, function(hash) {
  	    if (movies[hash]['rt_rating'] == undefined && 
  	        (movies[hash]['status'] != 'failed')) {
  	      return true;
  	    }
  	  });
  	  
  	  if (data.length > 1) retry_millis = retry_millis / 1.5;
  	  
    // Increase the check interval
    } else {
      retry_millis = retry_millis * 1.5;
    }
    
    // Recursively call loadMissingRatings() till we have all the ratings.
	  if (missing_ratings.length > 0) {
	    console.log('There are still ' + missing_ratings.length + ' ratings to load.  Retrying in ' + retry_millis + ' milliseconds.');
	    setTimeout((function() { return function() { self.loadMissingRatings(missing_ratings, retry_millis); } })(), retry_millis);
	  }
  }
  
  return self;
};

/**
 * TorrentzPage class methods.
 */
jQuery.extend(TorrentzPage, {
  
  /**
   * Use event delegation to capture clicks on the rottentomatoes links.
   */
  bindHandlersToRottenTomatoesLinks: function(element) {
    
    element.click(function(e) {
      var link = $(e.originalTarget);
      
      // Show more synopsis
      if (link.is('a#movie_synopsis_link')) {
        e.preventDefault();
        element.find('#movie_synopsis_all, #movie_synopsis_blurb').toggle();
        if (link.text() == '[More]') {
          link.text('[Less]');
        } else {
          link.text('[More]');
        }
      }    

      // Show more cast/crew information
      if (link.is('a#movie_castcrew_link')) {
        e.preventDefault();
        element.find('.movie_crew_all, .movie_crew_shortened, .movie_cast_shortened, .movie_cast_all').toggle();
        if (link.text() == '[See More Credits]') {
          link.text('[See Less Credits]');
        } else {
          link.text('[See More Credits]');
        }
      }
    });
  }
});