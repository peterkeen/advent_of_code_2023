require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.warning = false
  t.test_globs = ["*_test.rb", "day_*.rb"]
end

task :default => :test
