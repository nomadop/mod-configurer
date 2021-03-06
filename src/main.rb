#encoding: utf-8
require_relative 'mod'

def determine_mods(path)
  entries = Dir.entries(path).sort[2..-1]
  mod_dirs = entries.select { |e| File.directory?(File.join(path, e)) }
  mod_dirs.map { |dir| Mod.new(path, dir) }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def generate_mod_overrides(mods)
  "return {\n#{mods.map(&:output).join}}"
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_mod_info
  border black, strokewidth: 1
  @dir = para 'Directory:'
  @name = para 'Name:'
  @desc = para 'Description:'
  @author = para 'Author:'
  @version = para 'Version:'
  para 'Configs:'
  @configs = stack
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def open_output_folder
  folder = ask_open_folder
  @output_folder.text = folder
end

def render_config(config)
  para config.label + ':'
  options = config.options
  default = options.find { |o| o.data == (config.data || config.default) }
  list = list_box items: options.map(&:desc)
  list.choose(default.desc) if default
  list.change { config.set_by_desc(list.text) }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_configs(configs)
  return if configs.empty?

  configs.each do |config|
    flow { render_config(config) }
  end
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def select_mod(mod)
  mod.read_info unless mod.loaded
  @dir.replace "Directory: #{mod.dir}"
  @name.replace "Name: #{mod.name}"
  @desc.replace "Description: #{mod.desc}"
  @author.replace "Author: #{mod.author}"
  @version.replace "Version: #{mod.version}"
  @configs.clear { render_configs(mod.configs) }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def refresh_mod_list
  @checkers = []
  @mods.each do |mod|
    @checkers << check { |c| mod.enabled = c.checked? }
    button(mod.dir, width: 230) { select_mod(mod) }
  end
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def open_mod_folder
  folder = ask_open_folder
  @folder.text = folder
  @mods = determine_mods(folder)
  @mod_list.clear { refresh_mod_list }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_left
  para 'Select Mod Folder:'
  flow do
    @folder = edit_line(width: 200)
    button('Open') { open_mod_folder }
  end
  para 'Select Output Folder:'
  flow do
    @output_folder = edit_line(width: 200)
    button('Open') { open_output_folder }
    button 'Generate' do
      File.write(File.join(@output_folder.text, 'modoverrides.lua'), generate_mod_overrides(@mods))
    end
  end
  para 'Mod Info:'
  stack(width: 360) { render_mod_info }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def enable_all
  @checkers.each { |c| c.checked = true }
  @mods.each { |mod| mod.enabled = true }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def disable_all
  @checkers.each { |c| c.checked = false }
  @mods.each { |mod| mod.enabled = false }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_mod_list_header
  para 'Mod List:'
  button('Enable All') { enable_all }
  button('Disable All') { disable_all }
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_right
  flow { render_mod_list_header }
  @mod_list = flow
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

def render_app
  @mods = []
  @checkers = []
  flow(margin: 20) do
    @left = stack(width: 400) { render_left }
    @right = stack(width: 500) { render_right }
  end
rescue Exception => e
  alert "#{e.inspect},   #{e.backtrace}"
end

Shoes.app(width: 960) do
  render_app
end