# Clean out old objects from an AWS S3 bucket

# INSTALL
Use bundler to install gems. E.g. to install in vendor
<pre>
  bundle install --path vendor
</pre>

## Local
Copy settings file in conf dir.
<pre>
cp config/settings.yml.erb to confif/setting.yml
</pre>
Enter your AWS credentials and default host. E.g. of default host for Europe is s3-eu-west-1.amazonaws.com

## Remote
A Capistrano stage file is provided. Edit
* Address to server
* User and path to SSH key

Use Capistrano to deploy. When running deploy:setup, a settings.yml will be created for you on the server.
<pre>
  bundle exec cap aws deploy:setup
</pre>

Check the setup
<pre>
  bundle exec cap aws deploy:check
</pre>

Install
<pre>
  bundle exec cap aws deploy
</pre>

# Running S3 cleanser
s3_cleanser takes 3 arguments.
1 name of bucket
2 date. objects older than date will be deleted
3 marker. If you want to start with a specific marker. Useful when starting multiple s3_cleanser to delete objects in the same bucket.

Name of bucket and date are mandatory.

Delete objects in bucket _my_test_bucket_ that were last modified before 2012-08-01
<pre>
  bundle exec ruby s3_cleanser.rb my_test_bucket 2012-08-01
</pre>

Same as above but start deleting objects that start with d
<pre>
  bundle exec ruby s3_cleanser.rb my_test_bucket 2012-08-01 d
</pre>