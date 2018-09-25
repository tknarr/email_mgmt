desc "Set deployment flag to use database admin credentials on server"
task :dba_flag do
    on roles(:all) do |host|
        ENV['EMAIL_MGMT_DATABASE_ADMIN'] = host.properties.database_admin ? 'yes' : 'no'
    end
end

after "deploy:starting", "dba_flag"
