require 'rbconfig'

override_hdr = ENV['RUBY_HDR_DIR_OVERRIDE']
override_arch_hdr = ENV['RUBY_ARCH_HDR_DIR_OVERRIDE']

def apply_override(key, value)
  return if value.nil? || value.empty?
  RbConfig::CONFIG[key] = value
  RbConfig::MAKEFILE_CONFIG[key] = value
end

apply_override('rubyhdrdir', override_hdr)
apply_override('rubyarchhdrdir', override_arch_hdr)
