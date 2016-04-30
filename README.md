## Mocking Bird
> An easy way to setup mock responses by specifying mock URL, HTTP verb, Response headers and Response body. 

### Summary

The core idea behind this tool is having the ability to quickly and easily create mock responses for URLs that respond to HTTP verbs. This is 
achieved by an easy to use user interface that allows a user to specify a URL to mock, set the return HTTP status, headers and last 
but not the least the response body. All this can be achieved relatively quickly if the APIs require minimal client 
configuration (headers etc). The API's that respond with special headers can still be mocked by manually entering the relevant details.
Images can be served if they are placed in the `public` folder. To serve images from custom URLs, the images can be uploaded and the custom
URLs mocked with ease.

The cloning feature can be used if there is existing data available that cab be retrieved via HTTP GET requests, this can be quickly cloned into
the mock database and then modified according to the mocking needs.

The Implementation has been experimented and tested on OSX 10.10 and 10.11. User interface has been driven using recent versions of Safari (9.1) and Chrome (49.0).

### Installation

The main requirements of using the framework is the availability of `ruby` and sqllite on the users machine. The mock server 
can be setup to be used by a team or set up in a similar way for an individual user. The server has been tested on ruby version 
2.2.3 & sqlite3 gem 1.3.11. The same framework can be used if a different database is used such as mySQL, update gemfile with the 
relevant db-adapter gem and update the database.yml config file with connect connect parameters.

1. Install RVM & Ruby if needed
2. Install Sqlite  from [sqlite] (https://www.sqlite.org/download.html). Will help to manually browse the database if needed.
3. Download sqlite browser from [browser] (http://sqlitebrowser.org)
3. Clone git repository using `git clone https://github.com/mvemjsun/mock_server.git`
4. Run `bundle install` from within the code root directory to install needed gems.
5. Run `./start-mock.sh` which will start the service on port `9293`. You can now change your API endpoints to point to the mockserver. Just change the host part of the url to `<mock_server_ip:9293>`.
6. Visit `http://localhost:9293/mock/create` and get started.

Note: To start the server on any other port apart from `9293`, change the port number on the first line of the `config.ru` file.

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
Replace data can be created to look for 'replace strings' either by exect match or by regular expressions, there strings are matched and then replaced by their replacements silently in mock responses.

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
   at the moment, all server processing will be blocked while the latency is processed.
   
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
