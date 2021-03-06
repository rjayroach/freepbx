module Freepbx
  class Device < ApplicationRecord
    self.table_name = "#{asterisk_db}.devices"
    self.primary_key = :id

    # belongs_to :asterisk_user, :primary_key => 'user', :foreign_key => 'extension'
    belongs_to :user, class_name: 'Freepbx::User', foreign_key: 'extension'

    has_many :sip, class_name: 'Freepbx::Sip', primary_key: 'id', foreign_key: 'id'
    has_many :dahdi, class_name: 'Freepbx::Dahdi', primary_key: 'id', foreign_key: 'id'

    before_create :build_technology

    # NOTE: later implement a call by making a REST call via Adhearsion
    # This will use the dial field, initiate a call which will create a CDR automatically
    def originate(destination)
      Cdr.create(calldate: Time.now, src: id, dst: destination, disposition: 'ANSWERED')
    end

    def build_technology
      send("build_#{tech}")
    end

    def build_sip
      sip_array = []
      sip_array << { 'keyword' => 'secret',        'data' => id,                  'flags' => 2 }
      sip_array << { 'keyword' => 'dtmfmode',      'data' => 'rfc2833',           'flags' => 3 }
      sip_array << { 'keyword' => 'canreinvite',   'data' => 'no',                'flags' => 4 }
      sip_array << { 'keyword' => 'context',       'data' => 'from-internal',     'flags' => 5 }
      sip_array << { 'keyword' => 'host',          'data' => 'dynamic',           'flags' => 6 }
      sip_array << { 'keyword' => 'type',          'data' => 'friend',            'flags' => 7 }
      sip_array << { 'keyword' => 'nat',           'data' => 'yes',               'flags' => 8 }
      sip_array << { 'keyword' => 'port',          'data' => '5060',              'flags' => 9 }
      sip_array << { 'keyword' => 'quality',       'data' => 'yes',               'flags' => 10 }
      sip_array << { 'keyword' => 'callgroup',     'data' => '',                  'flags' => 11 }
      sip_array << { 'keyword' => 'pickupgroup',   'data' => '',                  'flags' => 12 }
      sip_array << { 'keyword' => 'disallow',      'data' => '',                  'flags' => 13 }
      sip_array << { 'keyword' => 'allow',         'data' => '',                  'flags' => 14 }
      sip_array << { 'keyword' => 'dial',          'data' => "SIP/#{id}",         'flags' => 15 }
      sip_array << { 'keyword' => 'accountcode',   'data' => '',                  'flags' => 16 }
      sip_array << { 'keyword' => 'mailbox',       'data' => "#{id}@device",      'flags' => 17 }
      sip_array << { 'keyword' => 'deny',          'data' => '0.0.0.0/0.0.0.0',   'flags' => 18 }
      sip_array << { 'keyword' => 'permit',        'data' => '0.0.0.0/0.0.0.0',   'flags' => 19 }
      sip_array << { 'keyword' => 'account',       'data' => id.to_s, 'flags' => 20 }
      sip_array << { 'keyword' => 'callerid',      'data' => "device <#{id}>",    'flags' => 21 }
      sip_array << { 'keyword' => 'record_in',     'data' => 'Adhoc',             'flags' => 22 }
      sip_array << { 'keyword' => 'record_out',    'data' => 'Adhoc',             'flags' => 23 }
      sip_array.each do |entry|
        asterisk_sip.build(id: id, keyword: entry['keyword'], data: entry['data'], flags: entry['flags'])
      end
    end

    # The device details are in different tables depending on the technology used
    # This method returns data from the related table as determined by the technology type
    def details
      send(tech)
    end
  end
end
