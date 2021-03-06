module Freepbx
  class Monitor < ApplicationRecord
    PROCESS_RECORDS_SIZE = 500

    # establish_connection "asteriskcdrdb" #if Rails.env.eql? 'production'
    # self.table_name = 'asteriskcdrdb.monitors'

    # MySQL: create index unq on ast_monitors (uniqueid);
    self.primary_key = 'uniqueid'

    # Fix for Strong parameters
    # attr_accessible :path, :uniqueid

    belongs_to :cdr, class_name: 'AsteriskCdr', primary_key: 'uniqueid', foreign_key: 'uniqueid'

    validates :path, :uniqueid, presence: true

    # Build an index of recordings based on files in the file system
    def self.reindex
      create_time = Time.zone.now
      Rails.logger.info "Begin reindex of monitors at #{create_time}"
      records = []
      # TODO: replace with truncate
      delete_all
      file_list.each do |path| # /var/spool/asterisk/monitor/OUT-1438-1223171759.1400.wav
        next unless (m = path.match(/(?:.*?-){2}(.*)/))
        uniqueid = m[1].gsub('.wav', '')  # '1223171759.1400'
        records.push "('#{path}', '#{uniqueid}', '#{create_time}', '#{create_time}')"
        next unless records.size == PROCESS_RECORDS_SIZE
        insert(records)
        records = []
      end
      insert(records) if records.size > 0 # If odd number of records exist then add them
      Rails.logger.info "Finished reindex of monitors at #{Time.zone.now}"
    end

    # Return an Enumerator of files on the file system (recursive)
    def self.file_list
      require 'find'
      dirs = ['/var/spool/asterisk/monitor']
      # for dir in dirs
      Find.find(dirs)
      # end
    end

    def self.insert(records)
      # Quotes around field names do not work with mysql
      sql = "INSERT INTO #{table_name} (path, uniqueid, created_at, updated_at) VALUES #{records.join(', ')}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
