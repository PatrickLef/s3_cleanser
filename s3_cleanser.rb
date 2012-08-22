require "rubygems"
require "bundler/setup"

require 'aws/s3'
require 'logger'
require 'time'
require 'pp'

SETTINGS = YAML::load(File.read('config/settings.yml'))

AWS::S3::DEFAULT_HOST.replace SETTINGS[:default_host]
AWS::S3::Base.establish_connection!(
    :access_key_id     => SETTINGS[:access_key_id],
    :secret_access_key => SETTINGS[:secret_access_key]
)

LOG = Logger.new 'log/s3_cleanser.log'

def show_info
  m =<<-MSG
  s3_cleanser bucket date marker
  \tbucket  = Name of the bucket that you want to delete objects in
  \tdate    = Objects older than this date will be deleted. Syntax is yyyy-mm-dd
  \tmarker  = Marker you want to start with
  Example: s3_cleanser my_bucket 2012-08-22
  MSG
  puts m
end

def clean_bucket bucket, timestamp, marker = ''
  old_marker  = nil
  nr_of_objects_deleted = 0
  while old_marker != marker
    old_marker = marker
    AWS::S3::Bucket.objects(bucket, :marker => marker, :max_keys => SETTINGS[:max_nr_of_keys]).each do |o|
      marker = o.key.to_s
      begin
        if Time.parse(o.about['last_modified']) < timestamp
           LOG.info "deleting #{o.key} from #{bucket}"
           AWS::S3::S3Object.delete o.key, bucket
           nr_of_objects_deleted += 1
        else
          LOG.info "keeping #{o.key} in #{bucket}"
        end
      rescue AWS::S3::NoSuchKey => e
        marker[0] = marker[0]+1 # jump ahead in the file listing with one character
        LOG.info "race about #{o.key} in #{bucket} jumping ahead to marker #{marker}"
        break
      end
    end
    LOG.info "-"*80
  end
  nr_of_objects_deleted
end

# Check input
if ARGV.length < 2 || !ARGV[1].match(/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/)
  show_info
  exit
end

bucket          = ARGV[0]
timestamp       = Time.parse ARGV[1]
starting_marker = ARGV[2] || ''

# Start deleting objects
LOG.info "Starting cleaning bucket #{bucket} from timestamp #{timestamp}"
nr_of_objects_deleted = clean_bucket bucket, timestamp, starting_marker
LOG.info "Finished cleaning bucket #{bucket} from timestamp #{timestamp}. #{nr_of_objects_deleted} where deleted"
