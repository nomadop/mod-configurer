require_relative 'mod_info'
require_relative 'mod_config'

class Mod
  attr_accessor :dir
  attr_accessor :enabled
  attr_reader :name
  attr_reader :desc
  attr_reader :author
  attr_reader :version
  attr_reader :configs
  attr_reader :loaded

  def initialize(path, dir)
    @dir = dir
    @info = ModInfo.new(path, dir)
    @configs = []
    @enabled = false
    @loaded = false
  end

  def read_info
    @info.read_info
    @name = @info.name
    @desc = @info.desc
    @author = @info.author
    @version = @info.version
    @configs = @info.options.map(&ModConfig.method(:new)).select(&:available?) if @info.options
    @loaded = true
  end

  def output
    "\t[\"#{@dir}\"] = { #{name_comment}\n\t\tenabled = #{ @enabled ? 'true' : 'false' },\n#{ @configs.map(&:output).join }\t},\n"
  end

  def name_comment
    "-- #{@name}" if @name && @name.size > 0
  end
end