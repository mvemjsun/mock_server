## Relax
> An easy way to setup mock responses by specifying mock URL, Response headers and Response body.

### Summary

The core idea behind the Mocking Bird is having the ability to quickly and easily create mock responses for ReST URLs. This is \
achieved by a user interface that allows the user to Specify a URL to mock, set the return HTTP status, headers and last \
but not the least the response body. All this can be achieved relatively fast if the ReST APIs require minimal client \
configuration (headers etc). The API's that require client configuration can still be mocked by manually entering the relevant details.

The Mocking framework is especially useful if the test data creation requires a lot of effort.

### Installation

The main requirements of using the framework is the availability of `ruby` and sqllite on the users machine. The mock server \
can be setup to be used by a team or set up in a similar way for an individual user. The server has been tested on ruby version \
2.2.3 & sqlite3 gem 1.3.11.

1. Install RVM & Ruby if needed
2. Install Sqlite  from [sqlite] (https://www.sqlite.org/download.html)
3. Download sqlite browser from [browser] (http://sqlitebrowser.org)
3. Clone git repository
4. Create database using the browser at `/db` and call it `mockserver.db` (You may delete the one from the repo)
4. Run `bundle install`
5. Run Rake task to create DB table as `rake db:migrate`
6. Run server `rackup` which will start the service on port `9292`. The server is now ready to use at localhost:9292

### Features

#### Create Mock

Create a mock by supplying relevant details on the form on the Home page. URL responses can be cloned if they require no \
client configuration.

#### Search Mock
Navigate to the search option and supply part of the mock name to search.

#### Update Mock
Edit an existing mock (search for it first).

### Home Screen
![](https://github.com/mvemjsun/mock_server/blob/master/public/img/home_screen.png?raw=true)
