module Freepbx
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.asterisk_db
      'asterisk' + (Rails.env.production? ? '' : "_#{Rails.env}")
    end
  end
end
