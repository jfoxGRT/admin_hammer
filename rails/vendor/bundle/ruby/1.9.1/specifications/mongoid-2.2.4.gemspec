# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongoid}
  s.version = "2.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Durran Jordan"]
  s.date = %q{2011-10-31 00:00:00.000000000Z}
  s.description = %q{Mongoid is an ODM (Object Document Mapper) Framework for MongoDB, written in Ruby.}
  s.email = ["durran@gmail.com"]
  s.files = ["lib/config/locales/bg.yml", "lib/config/locales/de.yml", "lib/config/locales/en-GB.yml", "lib/config/locales/en.yml", "lib/config/locales/es.yml", "lib/config/locales/fr.yml", "lib/config/locales/hi.yml", "lib/config/locales/hu.yml", "lib/config/locales/id.yml", "lib/config/locales/it.yml", "lib/config/locales/ja.yml", "lib/config/locales/kr.yml", "lib/config/locales/nl.yml", "lib/config/locales/pl.yml", "lib/config/locales/pt-BR.yml", "lib/config/locales/pt.yml", "lib/config/locales/ro.yml", "lib/config/locales/ru.yml", "lib/config/locales/sv.yml", "lib/config/locales/vi.yml", "lib/config/locales/zh-CN.yml", "lib/mongoid/atomic/modifiers.rb", "lib/mongoid/atomic/paths/embedded/many.rb", "lib/mongoid/atomic/paths/embedded/one.rb", "lib/mongoid/atomic/paths/embedded.rb", "lib/mongoid/atomic/paths/root.rb", "lib/mongoid/atomic/paths.rb", "lib/mongoid/atomic.rb", "lib/mongoid/attributes/processing.rb", "lib/mongoid/attributes.rb", "lib/mongoid/callbacks.rb", "lib/mongoid/collection.rb", "lib/mongoid/collections/master.rb", "lib/mongoid/collections/operations.rb", "lib/mongoid/collections/retry.rb", "lib/mongoid/collections.rb", "lib/mongoid/components.rb", "lib/mongoid/config/database.rb", "lib/mongoid/config/replset_database.rb", "lib/mongoid/config.rb", "lib/mongoid/contexts/enumerable/sort.rb", "lib/mongoid/contexts/enumerable.rb", "lib/mongoid/contexts/mongo.rb", "lib/mongoid/contexts.rb", "lib/mongoid/copyable.rb", "lib/mongoid/criteria.rb", "lib/mongoid/criterion/builder.rb", "lib/mongoid/criterion/complex.rb", "lib/mongoid/criterion/creational.rb", "lib/mongoid/criterion/exclusion.rb", "lib/mongoid/criterion/inclusion.rb", "lib/mongoid/criterion/inspection.rb", "lib/mongoid/criterion/optional.rb", "lib/mongoid/criterion/selector.rb", "lib/mongoid/cursor.rb", "lib/mongoid/default_scope.rb", "lib/mongoid/dirty.rb", "lib/mongoid/document.rb", "lib/mongoid/errors/callback.rb", "lib/mongoid/errors/document_not_found.rb", "lib/mongoid/errors/eager_load.rb", "lib/mongoid/errors/invalid_collection.rb", "lib/mongoid/errors/invalid_database.rb", "lib/mongoid/errors/invalid_field.rb", "lib/mongoid/errors/invalid_find.rb", "lib/mongoid/errors/invalid_options.rb", "lib/mongoid/errors/invalid_type.rb", "lib/mongoid/errors/mixed_relations.rb", "lib/mongoid/errors/mongoid_error.rb", "lib/mongoid/errors/too_many_nested_attribute_records.rb", "lib/mongoid/errors/unsaved_document.rb", "lib/mongoid/errors/unsupported_version.rb", "lib/mongoid/errors/validations.rb", "lib/mongoid/errors.rb", "lib/mongoid/extensions/array/deletion.rb", "lib/mongoid/extensions/false_class/equality.rb", "lib/mongoid/extensions/hash/criteria_helpers.rb", "lib/mongoid/extensions/hash/scoping.rb", "lib/mongoid/extensions/integer/checks.rb", "lib/mongoid/extensions/nil/collectionization.rb", "lib/mongoid/extensions/object/checks.rb", "lib/mongoid/extensions/object/reflections.rb", "lib/mongoid/extensions/object/substitutable.rb", "lib/mongoid/extensions/object/yoda.rb", "lib/mongoid/extensions/object_id/conversions.rb", "lib/mongoid/extensions/proc/scoping.rb", "lib/mongoid/extensions/string/checks.rb", "lib/mongoid/extensions/string/conversions.rb", "lib/mongoid/extensions/string/inflections.rb", "lib/mongoid/extensions/symbol/inflections.rb", "lib/mongoid/extensions/true_class/equality.rb", "lib/mongoid/extensions.rb", "lib/mongoid/extras.rb", "lib/mongoid/factory.rb", "lib/mongoid/fields/mappings.rb", "lib/mongoid/fields/serializable/array.rb", "lib/mongoid/fields/serializable/big_decimal.rb", "lib/mongoid/fields/serializable/bignum.rb", "lib/mongoid/fields/serializable/binary.rb", "lib/mongoid/fields/serializable/boolean.rb", "lib/mongoid/fields/serializable/date.rb", "lib/mongoid/fields/serializable/date_time.rb", "lib/mongoid/fields/serializable/fixnum.rb", "lib/mongoid/fields/serializable/float.rb", "lib/mongoid/fields/serializable/foreign_keys/array.rb", "lib/mongoid/fields/serializable/foreign_keys/object.rb", "lib/mongoid/fields/serializable/hash.rb", "lib/mongoid/fields/serializable/integer.rb", "lib/mongoid/fields/serializable/nil_class.rb", "lib/mongoid/fields/serializable/object.rb", "lib/mongoid/fields/serializable/object_id.rb", "lib/mongoid/fields/serializable/range.rb", "lib/mongoid/fields/serializable/set.rb", "lib/mongoid/fields/serializable/string.rb", "lib/mongoid/fields/serializable/symbol.rb", "lib/mongoid/fields/serializable/time.rb", "lib/mongoid/fields/serializable/time_with_zone.rb", "lib/mongoid/fields/serializable/timekeeping.rb", "lib/mongoid/fields/serializable.rb", "lib/mongoid/fields.rb", "lib/mongoid/finders.rb", "lib/mongoid/hierarchy.rb", "lib/mongoid/identity.rb", "lib/mongoid/identity_map.rb", "lib/mongoid/indexes.rb", "lib/mongoid/inspection.rb", "lib/mongoid/javascript/functions.yml", "lib/mongoid/javascript.rb", "lib/mongoid/json.rb", "lib/mongoid/keys.rb", "lib/mongoid/logger.rb", "lib/mongoid/matchers/all.rb", "lib/mongoid/matchers/default.rb", "lib/mongoid/matchers/exists.rb", "lib/mongoid/matchers/gt.rb", "lib/mongoid/matchers/gte.rb", "lib/mongoid/matchers/in.rb", "lib/mongoid/matchers/lt.rb", "lib/mongoid/matchers/lte.rb", "lib/mongoid/matchers/ne.rb", "lib/mongoid/matchers/nin.rb", "lib/mongoid/matchers/or.rb", "lib/mongoid/matchers/size.rb", "lib/mongoid/matchers/strategies.rb", "lib/mongoid/matchers.rb", "lib/mongoid/multi_database.rb", "lib/mongoid/multi_parameter_attributes.rb", "lib/mongoid/named_scope.rb", "lib/mongoid/nested_attributes.rb", "lib/mongoid/observer.rb", "lib/mongoid/paranoia.rb", "lib/mongoid/persistence/atomic/add_to_set.rb", "lib/mongoid/persistence/atomic/bit.rb", "lib/mongoid/persistence/atomic/inc.rb", "lib/mongoid/persistence/atomic/operation.rb", "lib/mongoid/persistence/atomic/pop.rb", "lib/mongoid/persistence/atomic/pull.rb", "lib/mongoid/persistence/atomic/pull_all.rb", "lib/mongoid/persistence/atomic/push.rb", "lib/mongoid/persistence/atomic/push_all.rb", "lib/mongoid/persistence/atomic/rename.rb", "lib/mongoid/persistence/atomic/sets.rb", "lib/mongoid/persistence/atomic/unset.rb", "lib/mongoid/persistence/atomic.rb", "lib/mongoid/persistence/deletion.rb", "lib/mongoid/persistence/insertion.rb", "lib/mongoid/persistence/modification.rb", "lib/mongoid/persistence/operations/embedded/insert.rb", "lib/mongoid/persistence/operations/embedded/remove.rb", "lib/mongoid/persistence/operations/insert.rb", "lib/mongoid/persistence/operations/remove.rb", "lib/mongoid/persistence/operations/update.rb", "lib/mongoid/persistence/operations.rb", "lib/mongoid/persistence.rb", "lib/mongoid/railtie.rb", "lib/mongoid/railties/database.rake", "lib/mongoid/railties/document.rb", "lib/mongoid/relations/accessors.rb", "lib/mongoid/relations/auto_save.rb", "lib/mongoid/relations/binding.rb", "lib/mongoid/relations/bindings/embedded/in.rb", "lib/mongoid/relations/bindings/embedded/many.rb", "lib/mongoid/relations/bindings/embedded/one.rb", "lib/mongoid/relations/bindings/referenced/in.rb", "lib/mongoid/relations/bindings/referenced/many.rb", "lib/mongoid/relations/bindings/referenced/many_to_many.rb", "lib/mongoid/relations/bindings/referenced/one.rb", "lib/mongoid/relations/bindings.rb", "lib/mongoid/relations/builder.rb", "lib/mongoid/relations/builders/embedded/in.rb", "lib/mongoid/relations/builders/embedded/many.rb", "lib/mongoid/relations/builders/embedded/one.rb", "lib/mongoid/relations/builders/nested_attributes/many.rb", "lib/mongoid/relations/builders/nested_attributes/one.rb", "lib/mongoid/relations/builders/referenced/in.rb", "lib/mongoid/relations/builders/referenced/many.rb", "lib/mongoid/relations/builders/referenced/many_to_many.rb", "lib/mongoid/relations/builders/referenced/one.rb", "lib/mongoid/relations/builders.rb", "lib/mongoid/relations/cascading/delete.rb", "lib/mongoid/relations/cascading/destroy.rb", "lib/mongoid/relations/cascading/nullify.rb", "lib/mongoid/relations/cascading/strategy.rb", "lib/mongoid/relations/cascading.rb", "lib/mongoid/relations/constraint.rb", "lib/mongoid/relations/cyclic.rb", "lib/mongoid/relations/embedded/atomic/operation.rb", "lib/mongoid/relations/embedded/atomic/pull.rb", "lib/mongoid/relations/embedded/atomic/push_all.rb", "lib/mongoid/relations/embedded/atomic/set.rb", "lib/mongoid/relations/embedded/atomic/unset.rb", "lib/mongoid/relations/embedded/atomic.rb", "lib/mongoid/relations/embedded/in.rb", "lib/mongoid/relations/embedded/many.rb", "lib/mongoid/relations/embedded/one.rb", "lib/mongoid/relations/embedded/sort.rb", "lib/mongoid/relations/macros.rb", "lib/mongoid/relations/many.rb", "lib/mongoid/relations/metadata.rb", "lib/mongoid/relations/nested_builder.rb", "lib/mongoid/relations/one.rb", "lib/mongoid/relations/options.rb", "lib/mongoid/relations/polymorphic.rb", "lib/mongoid/relations/proxy.rb", "lib/mongoid/relations/referenced/batch/insert.rb", "lib/mongoid/relations/referenced/batch.rb", "lib/mongoid/relations/referenced/in.rb", "lib/mongoid/relations/referenced/many.rb", "lib/mongoid/relations/referenced/many_to_many.rb", "lib/mongoid/relations/referenced/one.rb", "lib/mongoid/relations/reflections.rb", "lib/mongoid/relations/synchronization.rb", "lib/mongoid/relations/targets/enumerable.rb", "lib/mongoid/relations/targets.rb", "lib/mongoid/relations.rb", "lib/mongoid/safety.rb", "lib/mongoid/scope.rb", "lib/mongoid/serialization.rb", "lib/mongoid/sharding.rb", "lib/mongoid/state.rb", "lib/mongoid/threaded.rb", "lib/mongoid/timestamps/created.rb", "lib/mongoid/timestamps/updated.rb", "lib/mongoid/timestamps.rb", "lib/mongoid/validations/associated.rb", "lib/mongoid/validations/uniqueness.rb", "lib/mongoid/validations.rb", "lib/mongoid/version.rb", "lib/mongoid/versioning.rb", "lib/mongoid.rb", "lib/rack/mongoid/middleware/identity_map.rb", "lib/rack/mongoid.rb", "lib/rails/generators/mongoid/config/config_generator.rb", "lib/rails/generators/mongoid/config/templates/mongoid.yml", "lib/rails/generators/mongoid/model/model_generator.rb", "lib/rails/generators/mongoid/model/templates/model.rb.tt", "lib/rails/generators/mongoid/observer/observer_generator.rb", "lib/rails/generators/mongoid/observer/templates/observer.rb.tt", "lib/rails/generators/mongoid_generator.rb", "lib/rails/mongoid.rb", "CHANGELOG.md", "LICENSE", "README.md", "Rakefile"]
  s.homepage = %q{http://mongoid.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mongoid}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Elegant Persistance in Ruby for MongoDB.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_runtime_dependency(%q<tzinfo>, ["~> 0.3.22"])
      s.add_runtime_dependency(%q<mongo>, ["~> 1.3"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.5.0"])
      s.add_development_dependency(%q<bson_ext>, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.12"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
      s.add_development_dependency(%q<watchr>, ["~> 0.6"])
    else
      s.add_dependency(%q<activemodel>, ["~> 3.0"])
      s.add_dependency(%q<tzinfo>, ["~> 0.3.22"])
      s.add_dependency(%q<mongo>, ["~> 1.3"])
      s.add_dependency(%q<rdoc>, ["~> 3.5.0"])
      s.add_dependency(%q<bson_ext>, ["~> 1.3"])
      s.add_dependency(%q<mocha>, ["~> 0.9.12"])
      s.add_dependency(%q<rspec>, ["~> 2.6"])
      s.add_dependency(%q<watchr>, ["~> 0.6"])
    end
  else
    s.add_dependency(%q<activemodel>, ["~> 3.0"])
    s.add_dependency(%q<tzinfo>, ["~> 0.3.22"])
    s.add_dependency(%q<mongo>, ["~> 1.3"])
    s.add_dependency(%q<rdoc>, ["~> 3.5.0"])
    s.add_dependency(%q<bson_ext>, ["~> 1.3"])
    s.add_dependency(%q<mocha>, ["~> 0.9.12"])
    s.add_dependency(%q<rspec>, ["~> 2.6"])
    s.add_dependency(%q<watchr>, ["~> 0.6"])
  end
end