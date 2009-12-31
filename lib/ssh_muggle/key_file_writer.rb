module SSHMuggle
  class KeyfileWriter
    attr_accessor :out_directory

    def initialize(out_directory = 'keys')
      @out_directory = out_directory
    end

    def write(key)
      key_name = key[/\=\=\s([^@]+).*$/, 1].gsub(/[^A-Z|^a-z|^0-9]/, '_').downcase
      key_count = Dir["#{out_directory}/#{key_name}*.pub"].size

      key_name += "_#{key_count + 1}" if key_count > 0
      key_path = "#{out_directory}/#{key_name}.pub"

      File.open(key_path, 'w+') do |file|
        file.puts key
      end
    end
  end
end