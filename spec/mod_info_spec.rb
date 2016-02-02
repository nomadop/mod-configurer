require 'rspec'
require_relative '../src/mod_info'

describe 'Mod Info' do
  it 'should read modinfo lua' do
    mod_configer = ModInfo.new('mods', 'workshop-385006082')
    mod_configer.read_info
    expect(mod_configer.info).to eq({})
  end
end