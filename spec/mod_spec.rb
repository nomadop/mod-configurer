require 'rspec'
require_relative '../src/mod'

describe 'mod' do
  it 'should load workshop 378160973' do
    dir = 'workshop-378160973'
    mod = Mod.new('mods', dir)
    mod.read_info

    expect(mod.dir).to eq(dir)
    expect(mod.name).to eq('Global Positions')
    expect(mod.desc).to eq('By default, shows player arrows when the scoreboard is up, player icons on the minimap globally, and the same for campfires or firepits fueled by charcoal.')
    expect(mod.author).to eq('rezecib, Sarcen')
    expect(mod.version).to eq('1.3.5')
    expect(mod.configs.size).to eq(6)
  end

  it 'should load workshop 385006082' do
    dir = 'workshop-385006082'
    mod = Mod.new('mods', dir)
    mod.read_info

    expect(mod.dir).to eq(dir)
    expect(mod.name).to eq('DST Path Lights')
    expect(mod.desc).to eq('lights')
    expect(mod.author).to eq('Afro1967')
    expect(mod.version).to eq('1.6')
    expect(mod.configs.size).to eq(3)
  end
end