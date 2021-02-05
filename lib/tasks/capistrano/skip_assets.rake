if ENV['SKIP_ASSETS']
  Rake::Task['deploy:assets:precompile'].clear_actions
end