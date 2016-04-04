module Freepbx
  class Sip < ApplicationRecord
    self.table_name = "#{asterisk_db}.sip"

    belongs_to :device, class_name: 'Freepbx::Device', foreign_key: 'id'
  end
end
