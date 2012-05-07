class Link < ActiveRecord::Base
  attr_accessible :http_status, :in_url, :out_url, :visit_count

  validates :in_url, :out_url, :http_status, :presence => true
  validates :in_url, :uniqueness => true

end