require 'typescript-node'
require 'pry'

module Middleman
  class TypescriptExtension < Extension
    option :typescript_dir, 'typescripts', 'Set TypeScript dir.'
    option :target, 'ES5', 'Target version.(Default ES5)'
    option :no_implicit_any, true, 'Use --noImplicitAny option.(Default true)'
    def initialize(app, options_hash={}, &block)
      super
      return unless app.environment == :development

      app.set :typescript_dir, options.typescript_dir
      compile_options = ['--target', options.target]
      compile_options << '--noImplicitAny' if options.no_implicit_any
      app.set :typescript_compile_options, compile_options

      app.ready do
        files.changed do |file|
          next if File.extname(file) != '.ts'

          file_path = "#{Dir.pwd}/#{file}"
          result = TypeScript::Node.compile_file(file_path, *app.typescript_compile_options)
          if result.success?
            file_name = File.basename(file_path).gsub(/\.ts/, '.js')
            export_dir = source_dir + File.dirname(file_path).sub(source_dir, '').sub(app.typescript_dir, app.js_dir)
            Dir.mkdir export_dir unless Dir.exist? export_dir
            export_path = "#{export_dir}/#{file_name}"

            File.open export_path, "w" do |f|
              f.write result.js
            end
          else
            logger.info "TypeScript: #{result.stderr}"
          end
        end

        files.deleted do |file|
          next if File.extname(file) != '.ts'
          file_path = "#{Dir.pwd}/#{file}"
          file_name = File.basename(file_path).gsub(/\.ts/, '.js')
          unlink_dir = source_dir + File.dirname(file_path).sub(source_dir, '').sub(app.typescript_dir, app.js_dir)
          unlink_path = "#{unlink_dir}/#{file_name}"
          File.unlink unlink_path
        end
      end
    end
  end
end