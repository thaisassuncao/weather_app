## Weather Forecast App

A Ruby on Rails project that retrieves worldwide weather forecasts based on a user-provided address.
It geocodes the address, fetches weather, and shows current °C/°F, today’s high/low, and a multi-day forecast.

- Ruby 3.3.9 / Rails 7.2.2.2
- Caches weather every 30 min by postal/ZIP Code.

### Project Structure
```
├── app
│   ├── controllers
│   │   └── forecasts_controller.rb        # handles search, cache and display of forecasts
│   ├── helpers
│   │   └── forecasts_helper.rb            # labels/emojis and date formatting helpers
│   ├── services
│   │   ├── geocoding_service.rb           # wraps Nominatim geocoding
│   │   └── forecast_service.rb            # wraps Open-Meteo weather API and temperature rounding
│   ├── views
│   │   ├── layouts/application.html.erb   # handles background overlay
│   │   └── forecasts/new.html.erb         # search UI and forecast results
│   └── assets/stylesheets/application.css # responsive UI styling + themes
│
├── config
│   ├── application.rb                     # rails app configs
│   ├── environments/ (dev/test/prod)      # environment configs
│   └── locales/en.yml                     # i18n strings
│
├── spec
│   ├── requests/forecasts_spec.rb         # request specs (cache, errors, flows)
│   ├── services
│   │   ├── forecast_service_spec.rb       # unit tests for forecast service
│   │   └── geocoding_service_spec.rb      # unit tests for geocoding service
│   ├── support/webmock.rb                 # webmock setup
│   └── rails_helper.rb                    # rails rspec tests configs
│
├── .github/workflows/ci.yml               # GitHub Actions CI (RuboCop + RSpec)
├── .rubocop.yml                           # linter rules
├── Gemfile                                # dependencies
├── Rakefile                               # tasks
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

### Running Linter
```sh
$ bundle exec rubocop
```
