Architecture.without_auditing do
  Architecture.where(:name => 'aarch64').first_or_create
  Architecture.where(:name => 'armv7l').first_or_create
end
