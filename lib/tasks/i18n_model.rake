namespace :i18n do
  namespace :update do
    desc 'update i18n messages for mongoid models'
    task :models do
      Mongoid.models.each do |model|
        # on directory for on model:
        dir = model.to_s.underscore
        keys = {}
        keys["models.#{model.to_s.underscore}"] = model.to_s
        model.fields.each do |f, fo|
          next if f.start_with?('_')
          fname = fo.options[:as] || f
          key = "attributes.#{model.to_s.underscore}.#{fname.to_s.underscore}"
          keys[key] = fname.to_s
        end

        # for all models inherit from the model
        model.descendants.each do |child|
          keys["models.#{child.to_s.underscore}"] = child.to_s
          child.fields.each do |f, fo|
            next if f.start_with?('_')

            # only hold keys defined inside the child class
            next unless fo.options[:klass] == child

            fname = fo.options[:as] || f
            key = "attributes.#{child.to_s.underscore}.#{fname.to_s.underscore}"
            keys[key] = fname.to_s
          end
        end

        fkeys = keys.dup
        [:en, :ja, :zh].each do |lc|
          flc = I18nUtils::YamlFile.new("i18n/models/#{dir}/#{lc}.yml")
          fkeys.each { |k, dv| flc.add_with_gt("#{lc}.mongoid.#{k}", dv) }
          flc.rewrite!
        end
      end
    end
  end

  desc 'shortcut for update:models'
  task um: [:'update:models']
end
