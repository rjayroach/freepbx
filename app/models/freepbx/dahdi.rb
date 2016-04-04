module Freepbx
  class Dahdi < ApplicationRecord
    self.table_name = "#{asterisk_db}.dahdi"
  end
end
