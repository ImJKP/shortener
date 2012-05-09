class Link < ActiveRecord::Base
  attr_accessible :http_status, :short_path, :original_url, :visit_count

  validates :short_path, :original_url, :http_status, :presence => true
  validates :short_path, :uniqueness => true #adding a message here breaks things?

  validates_format_of :original_url, :with => /^(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  validates_format_of :short_path, :with => /\w/
  
  before_validation :cleanup_original_url
  before_validation :shorten
  


  N_CHARACTERS = 36

  def shorten
    if short_path.blank?
      self.short_path = Link.next_available_short_path
    end
  end

  def self.next_available_short_path(num_attempts = 0, n = nil)
    attempt = random_string(n)
    while where(:short_path => attempt).exists? || num_attempts > 5
       next_available_short_path(num_attempts + 1, n) 
    end
    if where(:short_path => attempt).exists?
      next_available_short_path(0, (n || shortest_available_length) + 1)
    end
    return attempt
  end
  
  def self.random_string(n = nil)
    rand(N_CHARACTERS**(n || shortest_available_length)).to_s(N_CHARACTERS)
  end 

  def self.shortest_available_length
    Math.log(count, N_CHARACTERS).ceil
  end

  def cleanup_original_url
    unless original_url.start_with?('http://') || original_url.start_with?('https://') || original_url.start_with?('ftp://')
      self.original_url = 'http://' << original_url
    end
  end

  def silly_length?(base_path)
    original_url.length < (base_path << short_path).length # find cleaner way for rails to tell me root url
  end

#  def original_domain
#    if original_url.starts_with?('http://')
#      stripped_url = original_url[7..-1]
#    elseif original_url.starts_with?('https://')
#      stripped_url = original_url[8..-1]
#    elseif original_url.starts_with?('ftp://')
#      stripped_url = original_url[6..-1]
#    end
#    PublicSuffix.parse(stripped_url).domain
#  end

  def same_original_url
    Link.where(:original_url => original_url)
  end

  def self.recently_created
    Link.last(5)
  end

end