#encoding: utf-8

class ModInfo
  attr_accessor :dir
  attr_accessor :info

  def initialize(path, dir)
    @dir = dir
    @status = 'name'
    @dash = 0
    @name = ''
    @data = ''
    @quota = false
    @string_value = false
    @brace_name_stack = []
    @brace_stack = []
    @dot = 0

    @info = {}
    @info_file = File.open(File.join(path, dir, 'modinfo.lua'))
    @info_alias = {
      desc: :description,
      options: :configuration_options,
    }
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

    @string_value = false
    @status = 'value'
  end

  def handle_others(c)
    return if @status == 'comment'

    case @status
      when 'nl'
        @name = c
        @data = ''
        @status = 'name'
      when 'brace_open'
        @brace_stack << {}
        @name = c
        @data = ''
        @status = 'name'
      when 'name' then @name += c
      when 'value' then @data += c
    end
  end

  def handle_endline
    return if @brace_stack.any? || @status == 'brace_open'
    return @status = @status_before_wrap if @status == 'wrap'
    @info[@name] = @string_value ? @data : eval(@data) if @status == 'value'

    @status = 'nl'
  end

  def handle_quota
    @quota = !@quota
    @string_value = true
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

    if @status == 'brace_open'
      @brace_stack << {}
    end

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

    return if @name.empty?
    last_brace_object = @brace_stack[-1]
    last_brace_object[@name] = @string_value ? @data : eval(@data) if @status == 'value'

    @name = ''
    @data = ''
    @status = 'name'
  end

  def handle_dot
    return if @status == 'comment'

    @dot += 1
    if @dot >= 2
      @status_before_wrap = @status
      @status = 'wrap'
      @dot = 0
    end
  end

  def byte(c)
    c.bytes[0]
  end

  def handle_char
    c = @info_file.readchar
    case byte(c)
      when byte(' '), byte("\t") then handle_space
      when byte('-') then handle_dash
      when byte("\r"), byte("\n") then handle_endline
      when byte('=') then handle_equal
      when byte('"') then handle_quota
      when byte('{') then handle_brace_open
      when byte('}') then handle_brace_close
      when byte(',') then handle_comma
      else handle_others(c)
    end
  end
end
