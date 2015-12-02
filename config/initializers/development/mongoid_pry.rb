require 'faker'
I18n.reload!
require 'factory_girl'
require 'table_print'
include FactoryGirl::Syntax::Methods

require_all root_join('spec/support/factories/*_factory.rb')
FactoryGirl.find_definitions

# rubocop:disable MethodLength

def indexes
  indexes = []
  Mongoid.models.each do |model|
    model.new.collection.indexes.each do |index|
      indexes << index['ns'] + ': ' + index['name']
    end
  end
  indexes
end

# list all mongoid models
def models
  children = []
  Mongoid.models.each do |model|
    children << model.to_s
    model.descendants.each do |child|
      inh = [child.to_s]
      sk = child.superclass
      while sk != model
        inh << sk.to_s
        sk = sk.superclass
        fail '!' if sk == Object
      end

      children << '   ' + inh.reverse.join(' < ')
    end
  end
  children
end

# list specific methods
def mop(model)
  klass = model.is_a?(Class) ? model : model.class

  ap '-- |FIELDS| --------------------------------'
  mets = {}
  klass.fields.each do |f, fo|
    next if f.to_s.match(/\A\_/)
    field_type = "#{fo.type} (< #{fo.options[:klass]})"
    fdef = fo.options[:klass] == klass ? "#{fo.type}" : field_type
    mets[f.to_s] = model.is_a?(Class) ? fdef : model.send(f)
  end
  ap mets.sort.to_h
  puts ''

  ap '-- |LOCAL METHODS| -------------------------'
  lmets(klass)
end

# list local defined methods
def lmets(model)
  klass = model.is_a?(Class) ? model : model.class
  model = model.new if model.is_a?(Class)
  mets = []
  klass.new.public_methods.each do |met|
    next unless model.method(met).source_location
    next unless model.method(met).source_location[0].match(root_join)
    pstrs = []
    model.method(met).parameters.each do |prm|
      str = prm[0] == :req ? "#{prm[1].to_s.dup}*" : prm[1].to_s.dup
      pstrs << str
    end
    mets << "#{met}(#{pstrs.join(', ')})"
  end
  mets
end

def drop_db
  fail 'can not drop production database' if ENV['RACK_ENV'] == 'production'
  # Mongoid.default_session.drop
  ::Mongoid::Clients.default.database.drop
end

def cleandb
  Mongoid.models.each do |model|
    next if %w(Sequence).include?(model.to_s)
    count = model.all.delete
    puts "[#{model}] deleted #{count}"
  end
  nil
end
