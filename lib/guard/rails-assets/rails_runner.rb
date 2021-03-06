require 'rake/dsl_definition'
module Guard

  class RailsAssets::RailsRunner

    def initialize(options)
      
    end

    # Methods to run the asset pipeline
    # Taken from - https://github.com/rails/rails/blob/master/actionpack/lib/sprockets/assets.rake
    module AssetPipeline
      extend self
      extend Rake::DSL
      
      def clean
        assets = Rails.application.config.assets
        public_asset_path = Rails.public_path + assets.prefix
        rm_rf public_asset_path, :secure => true
      end

      def precompile
        Sprockets::Helpers::RailsHelper

        assets = Rails.application.config.assets.precompile
        # Always perform caching so that asset_path appends the timestamps to file references.
        Rails.application.config.action_controller.perform_caching = true
        Rails.application.assets.precompile(*assets)
      end
    end

    def boot_rails
      @rails_booted ||= begin
        require "#{Dir.pwd}/config/environment.rb"
        true
      end
    end

    def run_compiler
      begin
        @failed = false
        AssetPipeline.clean
        AssetPipeline.precompile
      rescue => e
        puts "An error occurred compiling assets: #{e}"
        @failed = true
      end
    end

    # Runs the asset pipeline compiler.
    #
    # @return [ Boolean ] Whether the compilation was successful or not
    def compile_assets
      boot_rails
      run_compiler
      
      !failed?
    end

    def failed?
      @failed
    end
  end
end
