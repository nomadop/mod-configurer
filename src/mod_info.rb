#encoding: utf-8

class ModInfo
  attr_accessor :dir
  attr_accessor :info
  attr_accessor :configs

  def initialize(path, dir)
    @dir = dir
    @status = 'name'
    @dash = 0
    @name = ''
    @value = ''
    @quota = false
    @brace_name_stack = []
    @brace_stack = []

    @info = {}
    @info_file = File.open(File.join(path, dir, 'modinfo.lua'))
    @info_alias = {
      desc: :description,
      options: :configuration_options,
    }
    @configs = { enabled: false }
  end

  def output
    result = "\t[\"#{@dir}\"] = { #{ "-- #{@info['name']}" if @info['name'] && @info['name'].size > 0 }\n"
    @configs.each do |name, data|
      result += "\t\t#{name} = #{ data.is_a?(String) ? %("#{data}") : data },\n"
    end
    result += "\t},\n"
  end

  def enabled=(enabled)
    @configs[:enabled] = enabled
  end

  def enabled
    @configs[:enabled]
  end

  def set_config(name, data)
    @configs[name.to_sym] = data
  end

  def method_missing(method)
    @info[method.to_s] || @info[@info_alias[method].to_s]
  end

  def read_info
    until @info_file.eof
      handle_char
    end
  end

  def handle_dash
    return if @status == 'comment'

    @dash += 1
    if @dash >= 2
      @status = 'comment'
      @dash = 0
    end
  end

  def handle_space
    return if @status == 'comment'

    handle_others(' ') if @quota
  end

  def handle_equal
    return if @status == 'comment'

    @status = 'value'
  end

  def handle_others(c)
    return if @status == 'comment'

    case @status
      when 'nl'
        @name = c
        @value = ''
        @status = 'name'
      when 'brace_open'
        @brace_stack << {}
        @name = c
        @value = ''
        @status = 'name'
      when 'name' then @name += c
      when 'value' then @value += c
    end
  end

  def handle_endline
    return if @brace_stack.any? || @status == 'brace_open'
    @info[@name] = @value.is_a?(String) ? eval(@value) : @value if @status == 'value'

    @status = 'nl'
  end

  def handle_quota
    @quota = !@quota
    handle_others('"')
  end

  def handle_brace_open
    return if @status == 'comment'

    @brace_stack << [] if @status == 'brace_open'
    unless @name.empty?
      @brace_name_stack << @name
      @name = ''
    end
    @status = 'brace_open'
  end

  def handle_brace_close
    return if @status == 'comment'

    if @brace_stack.size == 1
      @info[@brace_name_stack.pop] = @brace_stack.pop
      @status = 'nl'
    else
      handle_comma
      current_brace_object = @brace_stack.pop
      last_brace_object = @brace_stack[-1]
      last_brace_object.is_a?(Array) ?
          last_brace_object << current_brace_object :
          last_brace_object[@brace_name_stack.pop] = current_brace_object
    end
  end

  def handle_comma
    return if @status == 'comment'
    return handle_others(',') if @quota

    return if @name.empty? || @value.empty?
    last_brace_object = @brace_stack[-1]
    last_brace_object[@name] = @value.is_a?(String) ? eval(@value) : @value if @status == 'value'

    @name = ''
    @value = ''
    @status = 'name'
  end

  def handle_char
    c = @info_file.readchar
    case c
      when /[ \t]/ then handle_space
      when '-' then handle_dash
      when /[\r\n]/ then handle_endline
      when '=' then handle_equal
      when '"' then handle_quota
      when '{' then handle_brace_open
      when '}' then handle_brace_close
      when ',' then handle_comma
      else handle_others(c)
    end
  end
end
