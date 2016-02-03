require_relative 'config_option'

class ModConfig
  attr_reader :name
  attr_reader :label
  attr_reader :default
  attr_reader :options
  attr_reader :data

  def initialize(config)
    @name = config['name']
    @label = config['label']
    @default = config['default']
    @options = config['options'].map { |o| ConfigOption.new(o['description'], o['data']) }
    @data = nil
  end

  def available?
    @name && @name.size > 0
  end

  def find_by_desc(desc)
    @options.find { |o| o.desc == desc }
  end

  def set_by_desc(desc)
    @data = find_by_desc(desc).data
  end

  def format_data
    data.is_a?(String) ? %("#{@data}") : @data
  end

  def output
    "\t\t#{name} = #{format_data},\n" if @data
  end
end