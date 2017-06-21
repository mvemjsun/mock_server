## Mocking Bird
> An easy way to setup mock responses by specifying mock URL, HTTP verb, Response headers and Response body. 

![](https://github.com/mvemjsun/mock_server/blob/master/public/img/architecture.png?raw=true)

### Quick Start

Ensure ruby and `bundler` are installed. RVM is a good way to manage rubies on your machine.

1. git clone `https://github.com/mvemjsun/mock_server.git`
2. Run `bundle install --without=test pg`
3. Navigate to `/db` folder and delete the supplied sqlite db (`mockserver.db` file).
4. Run `rake db:migrate` from the project root to create a fresh mock database.
5. Run `sh ./start-mock.sh` from the project root which starts the server on port 9293.
6. Visit `http://localhost:9293/mock/create` and create your mocks.
7. Direct your API requests to the mock server and have them served.

### Summary

The core idea behind this tool is having the ability to quickly and easily create mock responses for URLs that respond to HTTP verbs. It can help to
 test client devices against a mock server both manually and by using automated tests. All this is 
achieved by an easy to use user interface that allows a user to specify a URL to mock, set the return HTTP status, headers and last 
but not the least the response body. Mocking bird is slightly different from conventional mocking frameworks in that most of its features can be used even by
non-programmers who have got a basic knowledge of HTTP structure (headers, status codes & body); **also mocks need not be programmed into a language specific implementation. 
Set up once and use across multiple clients that use differing technologies.** 

The requests to the mock server can also be logged into the mock database if the environment variable `REQUEST_LOGGING` has been defined. 
The logs can also be cleared using an api call (see API support section below)

Images can be served using custom urls defined withing the mock server. Facility to upload the images is also
provided. Mocking can becomes super easy if there are existing API endpoints that return data, existing API responses be cloned via the GET button on the home 
page and then modified (currently only GET requests are supported).

The cloning feature can be used if there is existing data available that can be retrieved via HTTP GET requests, this can be quickly cloned into
the mock database and then modified.

The Implementation has been experimented and tested on OSX 10.10 and 10.11. User interface has been driven using recent versions of Safari (9.1) and Chrome (49.0).

The tool has been kept lightweight so that it can be installed and run on a developers/testers machine easily and quickly without any major software
or memory requirements.

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

Note 2: The script `./start-mock.sh` kills a process that runs at port `9293` before attempting to start the server again. Change the script if you wish to run 
the server at a different port in the `config.ru` file (line 1).

```
"Task Reading configuration ..."
"Task Establishing connection ..."
"Task Migrate ..."
"Migration version 1"

== 1 CreateMockdata: migrating ================================================
-- create_table(:mockdata, {})
   -> 0.0015s
-- execute("      CREATE UNIQUE INDEX \"unique_mock_data\"\n      
                  ON \"MOCKDATA\" (\"mock_request_url\",\"mock_http_verb\", \"mock_environment\", \"mock_state\")\n      
                  WHERE \"mock_state\" = 't'\n")
   -> 0.0004s
-- create_table(:missed_requests, {})
   -> 0.0006s
-- create_table(:replacedata, {})
   -> 0.0004s
-- create_table(:rubyscripts, {})
   -> 0.0003s
-- create_table(:httprequestlogs, {})
   -> 0.0006s
-- execute("      CREATE UNIQUE INDEX \"unique_replace_data\"\n      
                  ON \"REPLACEDATA\" (\"replaced_string\", \"mock_environment\", \"replace_state\")\n      
                  WHERE \"replace_state\" = 't'\n")
   -> 0.0002s
== 1 CreateMockdata: migrated (0.0047s) =======================================

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
Replace data can be created to look for 'replace strings' either by exact match or by regular expressions. This is a final
point in the request response time-line where the mock response that have been setup can still be modified before the
response is sent back to the client. Replace data can be applied only to the response body. For example there could be
a mock that has been set up to return the personal details of the user as

```
{
    "name" : "John",
    "middleName" : "Smith",
    "dob" : "1975-09-11",
    "postCode" : "TF12 6TR"
}
```

We could set up a replace data(s) so that the string `"dob" : "1975-09-11"` is replaced by `"dob" : "1955-01-11"`.

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
   is set up as `/say/(.*)/to/(.*)` then this will match `/say/hello/to/tom` or `/say/hola/to/rafael`.
   
   * Similarly if a mock URL is set up as `/get/me/item/(.*)` will match `/get/me/item/2345`. 
   
   When specifying wildcard in routes please ensure that any characters in the url that have a special meaning to the regex engine are escaped.
   For example if the url is `/get/me/a/book?id=98765` then you could have a wildcard route as `/get/me/a/book\?id=(.*)`.
    
### Basic Cookie support
   Mocks can be set up to return cookies. The cookie details should be entered ONE cookie in each line. The format is `cookieName cookieValue`.
   The cookie name should be followed by a space. If multiple cookies are required then enter each in its own line followed by a line-break.
   
   ```ruby
     userId 987656789
     token 7yser345abnjdlo12469sdfqws
     ssd yef32lvcdds
   ```
   The above will return 3 cookies with names userId, token and ssd with above values.

### Scripting Support (Experimental)
   A mock url can optionally be set up with scripting support. The scripts have to be written in Ruby. The mock responses
    specify the name of the before and after scripts when they are being created/updated. These scripts should have been
    created using the scripts option from the menu. The script names should be one or more scripts names ending `.rb`
    delimited by a `,` (comma) character.
    
   The scripts are evaluated with the `before` and `after` Sinatra filters and are evaluated in the context of  Sinatra
    request and responses. The scripts can for example be used to set up headers that need to be generated at run time or
    manipulate the response body before its sent back to the client.
    
   A word of CAUTION - Scripts are evaluated using ruby `eval` statement without any checks, so use them with caution.
    
   The mock_response build from the mock database is available in the instance variable `@mock_response`. 
    Example script that adds a custom header `X-AfterScript-Time` and sets the response body could be set as
    
   ```ruby
    headers({"X-AfterScript-Time" => "#{Time.now}"})
    @mock_response[:mock_data_response] = 'Hi Ya how are you'
    body @mock_response[:mock_data_response]
   ```
    
   This uses the Sinatra's functions `headers` and passes it a header hash. Similarly the `body` function is used to set
    an altered body.

### API support
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
   
   To set latency for individual url's you will have to use the 'Advanced options' and mention the name of a ruby script 
   with a sleep statement in it. So for example
   you could have `sleep1.rb` to `sleep5.rb` with `sleep n` statements in them (where `n` is from 1 to 5) to cause an
   artificial delay in the response.
   
   * Replace data rows in the DB can be activated using the endpoint
   
   The below will activate & decativate the replace data row with an id of 1. Any other rows that have the same replace string will be deactivated
   ```
   http://localhost:9293/mock/api/replace_data/activate/1
   http://localhost:9293/mock/api/replace_data/deactivate/1
   ```
   
   * Reset mock url's served count. The below url will set the served counts to 0 for all the mock urls in the database. This could be ideally be done at the start of a test.
   
   ```
   http://localhost:9293/mock/api/reset
   ```
   
   * Retrieve recent data from `httpRequestLog` table
   ```
   http://localhost:9293/mock/api/requestlog/recent
   ```
   
   * Retrieve `httpRequestLog` table data within a time range
   ```
   http://localhost:9293/mock/api/requestlog/range?from=2016-09-11 16:31:00&to=2016-09-11 16:32:11[&matching=<matchingString>]
   ```
   matching query parameter is optional, could have a value like `matching=/account`
   
   * Delete all data from the `httpRequestLog` table
   ```
   http://localhost:9293/mock/api/reset/requestlog
   ```
   
   * Update all rows in the Replacedata table 
   ```
   http://localhost:9293/mock/api/update/replacedata?string=xxx&with=yyy
   ```
   
   | API | Type |Description |
   | --- | --- | --- |
   | http://localhost:9293/mock/api/activate/1 | POST | Activate mock with id 1 |
   | http://localhost:9293/mock/api/deactivate/1  | POST | Deactivate mock with id 1 |
   | http://localhost:9293/latency/1  | POST | Set latency of response to 1 second |
   | http://localhost:9293/latency/2  | POST | Set latency of response to 2 seconds |
   | http://localhost:9293/mock/api/replace_data/activate/1 | POST | Set replace data mock 1 to active |
   | http://localhost:9293/mock/api/replace_data/deactivate/1 | POST | Set replace data mock 1 to Inactive |
   | http://localhost:9293/mock/api/reset | POST | Reset served counts for all the URLs to 0 |
   | http://localhost:9293/mock/api/requestlog/recent | GET | Return the recent logged requests |
   | http://localhost:9293/mock/api/requestlog/range?from=2016-09-11 16:31:00&to=2016-09-11 16:32:11[&matching=<matchingString>] | GET | Get recent log for a time range|
   | http://localhost:9293/mock/api/reset/requestlog | POST | Delete the request logs |
   | http://localhost:9293/mock/api/update/replacedata?string=xxx&with=yyy | POST | Update the replace data string to be replaced |
   
### Request log console
   The `Live Requests` tab on the web interface shows the requests being served by the mock server.
   ![](https://github.com/mvemjsun/mock_server/blob/master/public/img/request_logs.png?raw=true)
   
### Tests 
   
   There is some coverage for the main features of the mock server around creating mocks and search. The tests are run using `RSpec` & `Capybara` webkit driver.
   To run the tests ensure that you set the environment variable `ENVIRONMENT` and set it to `test`. Run the rake migration to create the test database using
   the command `ENVIRONMENT='test' rake db:migrate`. Then start the mock server using `ENVIRONMENT='test' sh ./start-mock.sh` from the project root.
   
   The tests can then be run using the command `rspec` from the project root.

### Data migration
   You could potentially experiment using the mock server using sqlite and if there is a need you could migrate data 
   from sqlite to another RDBMS such as Postgres. To do this you need to have the new DB already installed. 
   The `database.yml` should contain the setup info for it such as
   
   ```
   development_pg:
     adapter: postgresql
     encoding: unicode
     database: postgres
     pool: 5
     username: postgres
     password: postgres
     host: localhost
   ```
     
   Which points to a database named `postgres`. Run the rake task `rake db:migrate` with environment variable `ENVIRONMENT`
   set to `development_pg` (your name might be different) i.e `ENVIRONMENT=DEVELOPMENT_PG rake db:migrate`. This will create the database tables
   needed. Following this we need to migrate the individual table data. Which is 3 main tables; `mockdata`, `replacedata` & `rubyscripts`. We do this
   by running the 3 migration scripts one by one from the `db/datamigration` directory. Ensure that the scripts have the correct old and new
   environment names from the `database.yml` file. Once the data has been migrated successfully change the `Rakefile` or
   the environment variable `ENVIRONMENT` to point to the correct db from the `database.yml` file.
   
### TODO's
    * Video mocking
    * Support more verbs when cloning (currently limited to GET) 

### Caveat
    * The API URLs have to be unique across hosts as the mock server maintains only the mock url path and NOT the host part of the url.
    * The tool and framework has been setup to work against a single client and does not guarantee behaviour when used
      concurrently by more than one user. 

### Web interface   
 
 The tool/framework has an interface that lets you create and maintain mocking data.
 
#### Home Screen
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/home_screen.png?raw=true)

#### Advanced Options
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/advanced_options.png?raw=true)

#### Replace Strings
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/replace_screen.png?raw=true)

#### Search 
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/search_screen.png?raw=true)

#### Search Results
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/search_results.png?raw=true)

## Copyright and License

Copyright (c) 2016, mvemjsun.

Mocking bird source code is licensed under the [MIT License](LICENSE.md).
