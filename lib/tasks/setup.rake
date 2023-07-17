task :setup do
  unless File.exist?(Rails.root.join('.env'))
    FileUtils.cp Rails.root.join('.env.template'), Rails.root.join('.env')
  end
  system('overcommit --install')
  system('git config commit.template .commit-msg-template')
end
