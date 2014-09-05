require 'typescript-node'

module Middleman
  class TypescriptExtension < Extension
    option :typescript_dir, 'typescripts', 'Set TypeScript dir.'
    option :target, 'ES5', 'Target version.(Default ES5)'
    option :no_implicit_any, true, 'Use --noImplicitAny option.(Default true)'
    option :js_lib_dir, 'lib', 'Set JavaScript library dir.'
    def initialize(app, options_hash={}, &block)
      super

      app.set :typescript_dir, options.typescript_dir
      compile_options = ['--target', options.target]
      compile_options << '--noImplicitAny' if options.no_implicit_any
      app.set :typescript_compile_options, compile_options
      app.set :typescript_js_lib_dir, options.js_lib_dir

      app.ready do
        files.changed do |file|
          next if File.extname(file) != '.ts'

          file_path = "#{Dir.pwd}/#{file}"
          # Cannot call compile_to_js method...
          # compile_to_js(file_path)
          result = TypeScript::Node.compile_file(file_path, *app.typescript_compile_options)
          if result.success?
            export_dir = source_dir + File.dirname(file_path).sub(source_dir, '').sub(app.typescript_dir, app.js_dir)
            FileUtils.mkdir_p export_dir unless Dir.exist? export_dir

            file_name = File.basename(file_path).gsub(/\.ts/, '.js')
            File.open "#{export_dir}/#{file_name}", "w" do |f|
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

    def after_configuration
      remove_javascripts_without_library
      compile_typescripts
    end

    def after_build
      remove_typescripts_from_build_path
    end

    private
    def remove_javascripts_without_library
      app.logger.info "TypeScript: Removing JavaScript files..."
      Dir.glob("#{app.source_dir}/#{app.js_dir}/*") do |js_file_path|
        unless js_file_path.split('/').include? app.typescript_js_lib_dir
          unlink_recursive(js_file_path)
        end
      end
    end

    def compile_typescripts
      app.logger.info "TypeScript: Compiling TypeScript files..."
      Dir.glob("#{app.source_dir}/#{app.typescript_dir}/**/*") do |file_path|
        next if File.directory?(file_path) || File.extname(file_path) != '.ts'
        compile_to_js file_path
      end
    end

    def remove_typescripts_from_build_path
      typescript_build_path = "#{Dir.pwd}/#{app.build_dir}/#{app.typescript_dir}"
      if Dir.exist? typescript_build_path
        app.logger.info "TypeScript: Removing #{app.build_dir}/#{app.typescript_dir}/"
        unlink_recursive typescript_build_path
      end
    end

    def unlink_recursive(file_path, &block)
      if File.directory?(file_path)
        Dir.glob("#{file_path}/*") do |f|
          unlink_recursive f, &block
        end
        Dir.rmdir(file_path)
      else
        File.unlink file_path
      end
      block.call(file_path) if block
    end

    def compile_to_js(file_path)
      result = TypeScript::Node.compile_file(file_path, *app.typescript_compile_options)
      if result.success?
        file_name = File.basename(file_path).gsub(/\.ts/, '.js')
        export_dir = app.source_dir + File.dirname(file_path).sub(app.source_dir, '').sub(app.typescript_dir, app.js_dir)
        FileUtils.mkdir_p export_dir unless Dir.exist? export_dir
        export_path = "#{export_dir}/#{file_name}"

        File.open export_path, "w" do |f|
          f.write result.js
        end
      else
        app.logger.info "TypeScript: #{result.stderr}"
      end
    end
  end
end