require "pathname"
require "securerandom"
require "rails/generators"
require "rails/generators/rails/encryption_key_file/encryption_key_file_generator"
require "active_support/encrypted_configuration"
require "active_support/encrypted_file"

namespace :credentials do

    def credentials
        ActiveSupport::EncryptedConfiguration.new(
            config_path: "config/credentials.yml.enc",
            key_path: "config/master.key",
            env_key: "RAILS_MASTER_KEY",
            raise_if_missing_key: true
        )
    end

    def create_master_key_file
        key = ActiveSupport::EncryptedFile.generate_key
        File.open(credentials.key_path, "wb") do |f|
            f.write key
            f.chmod 0o600
        end
    end

    desc "Generate a new master encryption key and display on the console"
    task master: :environment do
        key = ActiveSupport::EncryptedFile.generate_key
        puts key
    end

    desc "Generate a new secret key base and display on the console"
    task secret: :environment do
        secret = SecureRandom.hex(64)
        puts secret
    end

    desc "Generate a new master key file, preserving encrypted credentials if any exist"
    task master_key: :environment do
        credentials_text = credentials.read
        create_master_key_file
        credentials.write(credentials_text) unless credentials_text.empty?
    end

    desc "Generate a new secret key base and update the encrypted credentials with it"
    task secret_key: :environment do
        credential_text = (File.exist?(credentials.key_path) && File.exist?(credentials.content_path)) ? credentials.read : ''
        create_master_key_file unless File.exist?(credentials.key_path)
        secret = SecureRandom.hex(64)
        if credential_text.empty?
            credentials.write 'secret_key_base: ' + secret + "\n"
        else
            credential_text.sub!(/secret_key_base:\s+\h+/, 'secret_key_base: ' + secret)
            credentials.write credential_text
        end
    end

end
