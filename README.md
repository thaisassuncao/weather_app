## Weather Forecast App

A Ruby on Rails project that retrieves worldwide weather forecasts based on a user-provided address.
The app geocodes the address, fetches weather data, and displays the current temperature, today’s high/low, and a 7-day extended forecast.

- Ruby 3.3.9 / Rails 7.2.2.2
- Caches weather 30 min by postal/ZIP (fallback: lat/lon).

### Project Structure
```
├── app
│   ├── controllers
│   │   └── forecasts_controller.rb   # Handles search and display of forecasts
│   ├── services
│   │   ├── geocoding_service.rb      # Wraps Nominatim geocoding
│   │   └── forecast_service.rb       # Wraps Open-Meteo weather API
│   └── views
│       └── forecasts/new.html.erb    # search UI + forecast results
│
├── spec
│   ├── requests/forecasts_spec.rb    # Request specs (cache, errors, flows)
│   ├── services                      # Unit tests for services
│   └── support/webmock.rb            # Stubs external HTTP calls
│
├── config                             # Rails app & environment configs
├── .github/workflows/ci.yml           # GitHub Actions CI (RSpec on push/PR)
├── Gemfile                            # Dependencies
└── README.md
```

### Running the Project

#### Install dependencies:
```sh
$ bundle install
```

#### Start the Rails server:
```sh
$ bin/rails s
```

#### Then visit on your browser:
http://localhost:3000

### Running Tests
```sh
$ bundle exec rspec
```
