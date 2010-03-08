#
# Module containing methods useful for trigram search.
#
module TrigramSearch
  
  # Conservative normalize a movie title.
  #
  # Usually called on a RT title to remove the year, leading The A and And etc.
  # This improves matching against TZ titles which often don't include these words
  # and often have incorrect years.
  #
  # Remove leading 'the', 'a' and 'and' from the title because the TZ title often doesn't
  # include these words.
  # Remove the year from titles that are just a few words because often the TZ
  # movie year is incorrect and this throws off the match for short titles.
  # Change '&' to 'and'.
  def self.conservative_normalize_title(title)
    title = title.strip.downcase.gsub(/[^\w\d ]/, '')
    title.gsub!(/^((the|a|and)\b)/, '')
    title.gsub!(/\s\d{4}$/, '')  # the year should be at the end
    title.gsub!(/\s&\s/, ' and ')
    title
  end
  
  # Normalize a search term by downcasing it, removing punctuation and multiple spaces
  def self.normalize_words(word)
    return word.strip.downcase.gsub(/[^\w\d ]/, '')
  end

  # Return the trigrams that form *word*, optionally appending a space on the end to
  # weight a match on the end of the word.  A space is always added to the beginning.
  def self.trigrams(word, weighted_end=false)
    word = ' ' + word + (weighted_end ? ' ' : '')
    return (0..word.length-3).collect { |idx| word[idx,3] }
  end

  # Return a degree of match between two titles as a percentage.  Based
  # on the percentage of trigrams from search_title that exist reference_titlein reference_title.
  #
  # @param conservative boolean default false.  Conservative matching
  # removes more superfluous
  def self.compare_titles(search_title, reference_title)
    return 0 if search_title.blank?
    
    search_trigrams = trigrams(search_title, true)     
    title_trigrams = trigrams(reference_title, true)     

    # Calculate the percentage of search trigrams matched in the movie title
    count = 0.0
    search_trigrams.each do |trigram|
      count += 1 if title_trigrams.include?(trigram)
    end
    
    percent = search_trigrams.empty? ? 0 : ((count / search_trigrams.length) * 100).to_i
  end
end