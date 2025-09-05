# Weather Forecast App

A Ruby on Rails project that retrieves worldwide weather forecasts based on a user-provided address.<br>
It geocodes the address, fetches the weather, and shows the current °C/°F, today’s high/low, and a multi-day forecast.<br>
It also caches forecasts for 30 minutes by postal/ZIP code.

### Dependencies
- Ruby [v3.3.9](https://www.ruby-lang.org/en/news/2025/07/24/ruby-3-3-9-released/)
- Rails [v7.2.2.2](https://rubygems.org/gems/rails/versions/7.2.2.2)

If needed, see the [official Ruby installation documentation](https://www.ruby-lang.org/en/documentation/installation/).

## Project Structure
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

## Running the Project Locally

#### 1. Install dependencies:
```sh
$ bundle install
```

#### 2. Start the Rails server:
```sh
$ bin/rails s
```

#### 3. Visit in your browser:
http://localhost:3000

## Running the Project in Docker

#### 1. Build and run the application:
```sh
$ make up
```

#### 2. Visit in your browser:
http://localhost:3000

## Running Tests
```sh
$ bundle exec rspec
```

## Running the Linter
```sh
$ bundle exec rubocop
```
