## Mocking Bird
> An easy way to setup mock responses by specifying mock URL, HTTP verb, Response headers and Response body. 

### Summary

The core idea behind this tool is having the ability to quickly and easily create mock responses for URLs that respond to HTTP verbs. This is 
achieved by an easy to use user interface that allows a user to specify a URL to mock, set the return HTTP status, headers and last 
but not the least the response body. Images can be served using custom urls defined withing the mock server. Facility to upload the images is also
provided. Mocking also becomes super easy if there are existing API endpoints that return data, this can be just cloned via the GET button on the home 
page and then modified.

The cloning feature can be used if there is existing data available that can be retrieved via HTTP GET requests, this can be quickly cloned into
the mock database and then modified.

The Implementation has been experimented and tested on OSX 10.10 and 10.11. User interface has been driven using recent versions of Safari (9.1) and Chrome (49.0).

### Installation

The main requirements of using the framework is the availability of `ruby` on the users machine. The mock server 
can be setup to be used by a team or set up in a similar way for an individual user. The server has been tested on ruby version 
2.2.3 & sqlite3 gem 1.3.11. The same framework can be used if a different database is used such as mySQL, update gemfile with the 
relevant db-adapter gem and update the database.yml config file with connect connect parameters.

1. Install RVM & Ruby if needed. RVM is a good way to control ruby installations on your machine. [RVM] (https://rvm.io)
2. Install Sqlite  from [sqlite] (https://www.sqlite.org/download.html). Will help to manually browse the database if needed.
3. Download sqlite browser from [browser] (http://sqlitebrowser.org)
3. Clone git repository using `git clone https://github.com/mvemjsun/mock_server.git`
4. Run `bundle install` from within the code root directory to install needed gems.
5. Run `./start-mock.sh` which will start the service on port `9293`. You can now change your API endpoints to point to the mockserver. Just change the host part of the url to `<mock_server_ip:9293>`.
6. Visit `http://localhost:9293/mock/create` and get started.

Note 1: To start the server on any other port apart from `9293`, change the port number on the first line of the `config.ru` file. 
The sample DB is from a mac machine , on other OS please delete the sample db and issue `sqlite3 mockserver.db` followed by `.save mockserver.db` on the sqlite3 prompt to create an empty DB in the `/db` folder Then issue
`rake db:migrate` from the root project folder. This will create the required DB tables in sqlite. Please ensure that you BACK UP any exiting DB files is this command is issued multiple times.

```
db mvemjsun$ sqlite3 mockserver.db
SQLite version 3.11.1 2016-03-03 16:17:53
Enter ".help" for usage hints.
sqlite> .schema
CREATE TABLE "schema_migrations" ("version" varchar NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "mockdata" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "mock_name" varchar, "mock_http_status" varchar, "mock_request_url" text, "mock_http_verb" text, "mock_data_response_headers" varchar, "mock_data_response" text(1000000), "mock_state" boolean, "mock_environment" varchar, "mock_content_type" varchar, "mock_served_times" integer, "has_before_script" boolean, "before_script_name" varchar, "has_after_script" boolean, "after_script_name" varchar, "profile_name" varchar, "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_mock_data"
      ON "MOCKDATA" ("mock_request_url","mock_http_verb", "mock_environment", "mock_state")
      WHERE "mock_state" = 't'
;
CREATE TABLE "missed_requests" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "url" varchar, "mock_http_verb" varchar, "mock_environment" varchar, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "replacedata" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "replace_name" varchar, "replaced_string" varchar, "replacing_string" varchar, "is_regexp" boolean, "mock_environment" varchar, "replace_state" boolean);
CREATE TABLE "rubyscripts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "script_name" varchar, "script_body" text, "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_replace_data"
      ON "REPLACEDATA" ("replaced_string", "mock_environment", "replace_state")
      WHERE "replace_state" = 't'
;
sqlite> .exit
db mvemjsun$
```

Note2: To check if port 9293 is already being used already on osx, use command `lsof -i:9293`. On Windows you may use `netstat -a -b`.

### Features

The tool can be used either as a standalone mock server on an individuals PC or setup as a team mock server. Its upto the team and user(s) to
decide what suits their needs.

#### Create Mock

Create a mock by supplying relevant details on the form on the Home page. URL responses can be cloned if they require no \
client configuration.

#### Search Mock
Navigate to the search option and supply part of the mock name to search.

#### Update Mock
Edit an existing mock (search for it first).

#### Clone in batch
If you have a set of Rest URL's that require no client configuration. Then you can clone the URLs into the mock database using the 
batch clone option.

#### Replace Data
Replace data can be created to look for 'replace strings' either by exact match or by regular expressions, there strings are matched and then replaced by their replacements silently in mock responses.

#### Upload Images
Images can be uploaded in case you want to mock url's that end with image names.

### Possible use cases

#### No existing data available
   Visit the /mock/create and create mock responses by entering response details manually
   
#### Existing data available
   This option could be used when minimal test data is available. We have two ways to mock here.
   * Visit the /mock/create page and clone an individual request into the mock database via the GET button (Menu - Home)
   * If you have a set of URL's to hand that return data then use them to clone in batch using the /mock/clone/batch (Menu - Clone Many). This
     option will clone the data into the database that you can then edit search followed by selecting a result and editing it.

#### Images
   * Images can be served if they are placed in /public/img directory and then the urls point to it like `http://xx.xx.xx.xx/img/captcha.png` 
     where `xx.xx.xx.xx` is the ip address of the mock server.
     
   * To serve custom image URLs, first upload the image onto the mock server and then create a mock URL with correct content type (png or jpeg)
     . The Image file name at the end of the url must match the uploaded image name (case sensitive). For example if you want to serve the URL
     `get/me/a/cat.png` then upload the image with name `cat.png` while creating the mock URL. Note only urls that end with an image file name
     can be served.

### Wildcard in routes (experimental)
   * If a mock url is set up with a wildcard character `*` in it then the mock server will attempt to match against the "wild" route if no exact match is found. For example if a mock URL
   is set up as `/say/*/to/*` then this will match `/say/hello/to/tom` or `/say/hola/to/rafael`.
   
   * Similarly if a mock URL is set up as `/get/me/item/*` will match `/get/me/item/2345`.
    
### Initial API support
   * Mockdata in the database can be activated or deactivated using its id.
   
   ```
      # To activate a mock url with Id = 1
      # http://localhost:9293/mock/api/activate/1
      
      # To deactivate a mock url with id = 1
      # http://localhost:9293/mock/api/deactivate/1
   ```
   Note that activating a url will deactivate any active form of that url in that test environment.
   
   * Latency of responses can be set using
   ```
   http://localhost:9293/latency/1 
   OR
   http://localhost:9293/latency/3
   ```
   This sets the global latency to 1 or 3 seconds for ALL mock responses. Please note that due to the blocking nature of the latency implementation
   at the moment, all server processing will be blocked while the latency is processed. The default latency is 0.
   
   To set the latency back to 0 issue the call `http://localhost:9293/latency/0`
   
### TODO's
    * Tests
    * Scripting support
    * Video mocking 
    
### Home Screen
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/home_screen.png?raw=true)

### Clone Many
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/batch_clone.png?raw=true)

### Replace Strings
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/replace_screen.png?raw=true)
