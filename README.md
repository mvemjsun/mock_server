## Mock Server
> An easy way to setup mock responses by specifying mock URL, HTTP verb, Response headers and Response body.

### Summary

The core idea behind this tool is having the ability to quickly and easily create mock responses for ReST URLs. This is 
achieved by a easy user interface that allows the user to Specify a URL to mock, set the return HTTP status, headers and last 
but not the least the response body. All this can be achieved relatively fast if the ReST APIs require minimal client 
configuration (headers etc). The API's that require client configuration can still be mocked by manually entering the relevant details.
This version does not have HTTPs support or serving any BLOB data. Images can be however served if they are placed in the `public` folder.

The Mocking framework is especially useful if the test data creation requires a lot of effort.

### Installation

The main requirements of using the framework is the availability of `ruby` and sqllite on the users machine. The mock server 
can be setup to be used by a team or set up in a similar way for an individual user. The server has been tested on ruby version 
2.2.3 & sqlite3 gem 1.3.11. The same framework can be used if a different database is used such as mySQL, update gemfile with the 
relevant db-adapter gem and update the database.yml config file with connect connect parameters.

1. Install RVM & Ruby if needed
2. Install Sqlite  from [sqlite] (https://www.sqlite.org/download.html). Will help to manually browse the database if needed.
3. Download sqlite browser from [browser] (http://sqlitebrowser.org)
3. Clone git repository using `git clone https://github.com/mvemjsun/mock_server.git`
4. Create database using the browser at `/db` and call it `mockserver.db` or you may continue to use the one in the repo.
4. Run `bundle install` to install all needed gems.
5. Run Rake task to create DB table as `rake db:migrate` if you DONT want to use the db in the repo.
6. Run server `RACK_ENV=production rackup > /dev/null 2>&1 &` which will start the service on port `9293`. You can now change your API endpoints to point to the mockserver. Just change the host part of the url to `<mock_server_ip:9293>`.
7. Visit http://localhost:9292/mock/create and get started.

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

### Possible use cases

#### No existing data available
   Visit the /mock/create and create mock responses by entering response details manually
   
#### Existing data available
   This option could be used when minimal test data is available. We have two ways to mock here
   * Visit the /mock/create page and clone an individual request into the mock database via the GET button (Menu - Home)
   * If you have a set of URL's to hand that return data then use them to clone in batch using the /mock/clone/batch (Menu - Clone Many). This
     option will clone the data into the database that you can then edit search followed by selecting a result and editing it.

#### Images
   Images can be served if they are placed in /public/img directory and then the urls point to it like `http://xx.xx.xx.xx/img/captcha.png` where `xx.xx.xx.xx` is the ip address of the mock server.

### Home Screen
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/home_screen.png?raw=true)

### Clone Many
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/batch_clone.png?raw=true)

### Replace Strings
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/replace_screen.png?raw=true)
