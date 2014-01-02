# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{activesupport}
  s.version = "3.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson"]
  s.date = %q{2011-11-18}
  s.description = %q{A toolkit of support libraries and Ruby core extensions extracted from the Rails framework. Rich support for multibyte strings, internationalization, time zones, and testing.}
  s.email = %q{david@loudthinking.com}
  s.files = ["CHANGELOG", "README.rdoc", "lib/active_support/inflector/transliterate.rb", "lib/active_support/inflector/inflections.rb", "lib/active_support/inflector/methods.rb", "lib/active_support/values/time_zone.rb", "lib/active_support/values/unicode_tables.dat", "lib/active_support/locale/en.yml", "lib/active_support/cache.rb", "lib/active_support/time_with_zone.rb", "lib/active_support/cache/mem_cache_store.rb", "lib/active_support/cache/memory_store.rb", "lib/active_support/cache/synchronized_memory_store.rb", "lib/active_support/cache/file_store.rb", "lib/active_support/cache/strategy/local_cache.rb", "lib/active_support/cache/compressed_mem_cache_store.rb", "lib/active_support/time/autoload.rb", "lib/active_support/builder.rb", "lib/active_support/all.rb", "lib/active_support/concern.rb", "lib/active_support/xml_mini/nokogiri.rb", "lib/active_support/xml_mini/rexml.rb", "lib/active_support/xml_mini/libxml.rb", "lib/active_support/xml_mini/jdom.rb", "lib/active_support/xml_mini/libxmlsax.rb", "lib/active_support/xml_mini/nokogirisax.rb", "lib/active_support/string_inquirer.rb", "lib/active_support/option_merger.rb", "lib/active_support/memoizable.rb", "lib/active_support/descendants_tracker.rb", "lib/active_support/message_encryptor.rb", "lib/active_support/benchmarkable.rb", "lib/active_support/dependencies.rb", "lib/active_support/json/decoding.rb", "lib/active_support/json/encoding.rb", "lib/active_support/json/backends/jsongem.rb", "lib/active_support/json/backends/yaml.rb", "lib/active_support/json/backends/yajl.rb", "lib/active_support/json/variable.rb", "lib/active_support/test_case.rb", "lib/active_support/inflections.rb", "lib/active_support/duration.rb", "lib/active_support/deprecation.rb", "lib/active_support/dependencies/autoload.rb", "lib/active_support/deprecation/reporting.rb", "lib/active_support/deprecation/proxy_wrappers.rb", "lib/active_support/deprecation/behaviors.rb", "lib/active_support/deprecation/method_wrappers.rb", "lib/active_support/base64.rb", "lib/active_support/ordered_hash.rb", "lib/active_support/json.rb", "lib/active_support/gzip.rb", "lib/active_support/notifications/fanout.rb", "lib/active_support/notifications/instrumenter.rb", "lib/active_support/inflector.rb", "lib/active_support/whiny_nil.rb", "lib/active_support/file_update_checker.rb", "lib/active_support/backtrace_cleaner.rb", "lib/active_support/time.rb", "lib/active_support/log_subscriber.rb", "lib/active_support/multibyte/chars.rb", "lib/active_support/multibyte/exceptions.rb", "lib/active_support/multibyte/unicode.rb", "lib/active_support/multibyte/utils.rb", "lib/active_support/rescuable.rb", "lib/active_support/version.rb", "lib/active_support/multibyte.rb", "lib/active_support/configurable.rb", "lib/active_support/xml_mini.rb", "lib/active_support/ordered_options.rb", "lib/active_support/railtie.rb", "lib/active_support/i18n_railtie.rb", "lib/active_support/log_subscriber/test_helper.rb", "lib/active_support/lazy_load_hooks.rb", "lib/active_support/buffered_logger.rb", "lib/active_support/core_ext/float/rounding.rb", "lib/active_support/core_ext/date/zones.rb", "lib/active_support/core_ext/date/freeze.rb", "lib/active_support/core_ext/date/acts_like.rb", "lib/active_support/core_ext/date/conversions.rb", "lib/active_support/core_ext/date/calculations.rb", "lib/active_support/core_ext/class.rb", "lib/active_support/core_ext/kernel/requires.rb", "lib/active_support/core_ext/kernel/reporting.rb", "lib/active_support/core_ext/kernel/agnostics.rb", "lib/active_support/core_ext/kernel/singleton_class.rb", "lib/active_support/core_ext/kernel/debugger.rb", "lib/active_support/core_ext/numeric.rb", "lib/active_support/core_ext/numeric/time.rb", "lib/active_support/core_ext/numeric/bytes.rb", "lib/active_support/core_ext/time/zones.rb", "lib/active_support/core_ext/time/acts_like.rb", "lib/active_support/core_ext/time/conversions.rb", "lib/active_support/core_ext/time/marshal.rb", "lib/active_support/core_ext/time/calculations.rb", "lib/active_support/core_ext/time/publicize_conversion_methods.rb", "lib/active_support/core_ext/module.rb", "lib/active_support/core_ext/load_error.rb", "lib/active_support/core_ext/rexml.rb", "lib/active_support/core_ext/cgi.rb", "lib/active_support/core_ext/big_decimal.rb", "lib/active_support/core_ext/file/path.rb", "lib/active_support/core_ext/file/atomic.rb", "lib/active_support/core_ext/array.rb", "lib/active_support/core_ext/array/random_access.rb", "lib/active_support/core_ext/array/uniq_by.rb", "lib/active_support/core_ext/array/access.rb", "lib/active_support/core_ext/array/conversions.rb", "lib/active_support/core_ext/array/wrap.rb", "lib/active_support/core_ext/array/extract_options.rb", "lib/active_support/core_ext/array/grouping.rb", "lib/active_support/core_ext/uri.rb", "lib/active_support/core_ext/integer/inflections.rb", "lib/active_support/core_ext/integer/time.rb", "lib/active_support/core_ext/integer/multiple.rb", "lib/active_support/core_ext/logger.rb", "lib/active_support/core_ext/benchmark.rb", "lib/active_support/core_ext/proc.rb", "lib/active_support/core_ext/range.rb", "lib/active_support/core_ext/module/attribute_accessors.rb", "lib/active_support/core_ext/module/attr_accessor_with_default.rb", "lib/active_support/core_ext/module/delegation.rb", "lib/active_support/core_ext/module/deprecation.rb", "lib/active_support/core_ext/module/method_names.rb", "lib/active_support/core_ext/module/synchronization.rb", "lib/active_support/core_ext/module/remove_method.rb", "lib/active_support/core_ext/module/aliasing.rb", "lib/active_support/core_ext/module/reachable.rb", "lib/active_support/core_ext/module/anonymous.rb", "lib/active_support/core_ext/module/introspection.rb", "lib/active_support/core_ext/module/attr_internal.rb", "lib/active_support/core_ext/string/behavior.rb", "lib/active_support/core_ext/string/access.rb", "lib/active_support/core_ext/string/inflections.rb", "lib/active_support/core_ext/string/conversions.rb", "lib/active_support/core_ext/string/multibyte.rb", "lib/active_support/core_ext/string/filters.rb", "lib/active_support/core_ext/string/output_safety.rb", "lib/active_support/core_ext/string/encoding.rb", "lib/active_support/core_ext/string/starts_ends_with.rb", "lib/active_support/core_ext/string/strip.rb", "lib/active_support/core_ext/string/exclude.rb", "lib/active_support/core_ext/string/interpolation.rb", "lib/active_support/core_ext/string/xchar.rb", "lib/active_support/core_ext/process/daemon.rb", "lib/active_support/core_ext/range/include_range.rb", "lib/active_support/core_ext/range/blockless_step.rb", "lib/active_support/core_ext/range/conversions.rb", "lib/active_support/core_ext/range/overlaps.rb", "lib/active_support/core_ext/big_decimal/conversions.rb", "lib/active_support/core_ext/date_time/zones.rb", "lib/active_support/core_ext/date_time/acts_like.rb", "lib/active_support/core_ext/date_time/conversions.rb", "lib/active_support/core_ext/date_time/calculations.rb", "lib/active_support/core_ext/kernel.rb", "lib/active_support/core_ext/regexp.rb", "lib/active_support/core_ext/string.rb", "lib/active_support/core_ext/class/inheritable_attributes.rb", "lib/active_support/core_ext/class/attribute_accessors.rb", "lib/active_support/core_ext/class/delegating_attributes.rb", "lib/active_support/core_ext/class/subclasses.rb", "lib/active_support/core_ext/class/attribute.rb", "lib/active_support/core_ext/enumerable.rb", "lib/active_support/core_ext/integer.rb", "lib/active_support/core_ext/process.rb", "lib/active_support/core_ext/hash.rb", "lib/active_support/core_ext/float.rb", "lib/active_support/core_ext/file.rb", "lib/active_support/core_ext/name_error.rb", "lib/active_support/core_ext/cgi/escape_skipping_slashes.rb", "lib/active_support/core_ext/hash/diff.rb", "lib/active_support/core_ext/hash/keys.rb", "lib/active_support/core_ext/hash/conversions.rb", "lib/active_support/core_ext/hash/deep_merge.rb", "lib/active_support/core_ext/hash/indifferent_access.rb", "lib/active_support/core_ext/hash/slice.rb", "lib/active_support/core_ext/hash/except.rb", "lib/active_support/core_ext/hash/reverse_merge.rb", "lib/active_support/core_ext/exception.rb", "lib/active_support/core_ext/object.rb", "lib/active_support/core_ext/object/try.rb", "lib/active_support/core_ext/object/to_param.rb", "lib/active_support/core_ext/object/returning.rb", "lib/active_support/core_ext/object/blank.rb", "lib/active_support/core_ext/object/duplicable.rb", "lib/active_support/core_ext/object/acts_like.rb", "lib/active_support/core_ext/object/conversions.rb", "lib/active_support/core_ext/object/with_options.rb", "lib/active_support/core_ext/object/to_query.rb", "lib/active_support/core_ext/object/to_json.rb", "lib/active_support/core_ext/object/instance_variables.rb", "lib/active_support/callbacks.rb", "lib/active_support/hash_with_indifferent_access.rb", "lib/active_support/notifications.rb", "lib/active_support/basic_object.rb", "lib/active_support/core_ext.rb", "lib/active_support/testing/setup_and_teardown.rb", "lib/active_support/testing/performance.rb", "lib/active_support/testing/deprecation.rb", "lib/active_support/testing/default.rb", "lib/active_support/testing/declarative.rb", "lib/active_support/testing/pending.rb", "lib/active_support/testing/assertions.rb", "lib/active_support/testing/isolation.rb", "lib/active_support/i18n.rb", "lib/active_support/ruby/shim.rb", "lib/active_support/message_verifier.rb", "lib/active_support/secure_random.rb", "lib/active_support.rb"]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{activesupport}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A toolkit of support libraries and Ruby core extensions extracted from the Rails framework.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
