require "jekyll"
require "terser"

module Jekyll
  class TerserJS < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)
      @site = site
      # Only minify in production
      return unless Jekyll.env == "production"

      site.static_files.each do |file|
        if file.path.end_with?(".js") && !file.path.include?(".min.js")
          minify(file)
        end
      end
    end

    private

    def minify(file)
      # Skip if source file doesn't exist
      return unless File.exist?(file.path)
      
      begin
        input = File.read(file.path)
        # Terser minification logic
        output = Terser.compile(input)
        
        # Write back to the original file path
        File.open(file.path, "w") { |f| f.write(output) }
      rescue => e
        Jekyll.logger.warn "Terser:", "Could not minify #{file.path}: #{e.message}"
      end
    end
  end
end
