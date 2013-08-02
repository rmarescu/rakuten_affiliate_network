# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :test do
  watch(%r{^test/.+_test\.rb$})
  watch("test/test_helper.rb") { "test" }

  watch(%r{^app/models/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^app/validators/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
end
