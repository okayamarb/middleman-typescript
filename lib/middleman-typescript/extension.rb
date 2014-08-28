require 'typescript-node'

module Middleman
  class TypescriptExtension < Extension
    option :typescript_dir, 'typescripts', 'Set TypeScript dir.'
    def initialize(app, options_hash={}, &block)
      super
      app.set :typescript_dir, options.typescript_dir

      return unless app.environment == :development

      app.ready do
        files.changed do |file|
          next if File.extname(file) != '.ts'

          file_path = "#{Dir.pwd}/#{file}"
          result = TypeScript::Node.compile_file(file_path, '--target', 'ES5')
          if result.success?
            file_name = File.basename(file_path).gsub(/\.ts/, '.js')
            export_dir = source_dir + File.dirname(file_path).sub(source_dir, '').sub(app.typescript_dir, app.js_dir)
            Dir.mkdir export_dir unless Dir.exist? export_dir
            export_path = "#{export_dir}/#{file_name}"

            File.open export_path, "w" do |f|
              f.write result.js
            end
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