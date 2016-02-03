require 'rspec'
require_relative '../src/mod_config'

describe 'Mod Config' do
  before(:each) do
    @option = {
      'name' => 'MAXSTACKSIZE',
      'label' => 'Max stacksize',
      'options' => [
        {'description' => '20', 'data' => 20},
        {'description' => '40', 'data' => 40},
        {'description' => '60', 'data' => 60},
        {'description' => '80', 'data' => 80},
        {'description' => '99', 'data' => 99},
        {'description' => '120', 'data' => 120},
        {'description' => '150', 'data' => 150},
        {'description' => '200', 'data' => 200},
        {'description' => '250', 'data' => 250},
      ],
      'default' => 99,
    }
    @config = ModConfig.new(@option)
  end

  it 'should create by configuration option' do
    expect(@config.name).to eq('MAXSTACKSIZE')
    expect(@config.label).to eq('Max stacksize')
    expect(@config.default).to eq(99)
    expect(@config.options.size).to eq(9)
    expect(@config.data).to eq(nil)
  end

  it 'should find by desc' do
    option = @config.find_by_desc('120')
    expect(option).to eq(ConfigOption.new('120', 120))
  end

  it 'should set by desc' do
    @config.set_by_desc('120')
    expect(@config.data).to eq(120)
  end

  it 'should output to lua part' do
    @config.set_by_desc('250')
    expect(@config.output).to eq("\t\tMAXSTACKSIZE = 250,\n")
  end

  it 'should not available when name is empty' do
    config = ModConfig.new({
      'name' => '',
      'label' => '',
      'options' => [
        {'description' => '', 'data' => 0},
      ],
      'default' => 0,
    })

    expect(config.available?).to be(false)
  end
end