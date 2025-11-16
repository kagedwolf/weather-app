guard "livereload" do
  # Watch view templates (ERB/HAML/Slim)
  watch(%r{app/views/.+\.(erb|haml|slim)$})

  # Watch helpers and routes so changes that affect rendering trigger reloads
  watch(%r{app/helpers/.+\.rb$})
  watch(%r{config/locales/.+\.yml$})

  # Watch built assets and public files
  watch(%r{app/assets/builds/.+})
  watch(%r{public/.+})

  # Watch JavaScript and CSS source files
  watch(%r{app/javascript/.+})
  watch(%r{app/assets/stylesheets/.+})
end
