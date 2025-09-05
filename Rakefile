# frozen_string_literal: true

require_relative "config/application"
Rails.application.load_tasks

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop)
rescue LoadError
  # Docker fallback for RuboCop not installed
end
