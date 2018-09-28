desc "Link the shared puma.rb configuration file into the application"
task :link_puma_config do
    on roles(:all) do |host|
        # TODO
    end
end

after "deploy:symlink:linked_files", "link_puma_config"
