# Version numbering: http://wiki.github.com/sandal/prawn/development-roadmap
PRAWN_VERSION = "0.10.0.howrah" 

Gem::Specification.new do |spec|
  spec.name = "howrah-prawn"
  spec.version = PRAWN_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Based on Prawn, a fast and nimble PDF generator for Ruby"
  spec.files =  Dir.glob("{examples,lib,spec,vendor,data}/**/**/*") +
                      ["Rakefile"]
  spec.require_path = "lib"

  spec.test_files = Dir[ "test/*_test.rb" ]
  spec.has_rdoc = true
  spec.extra_rdoc_files = %w{HACKING README LICENSE COPYING}
  spec.rdoc_options << '--title' << 'Prawn Documentation' <<
                       '--main'  << 'README' << '-q'
  spec.author = "Kristian Mandrup"
  spec.email = ""
  spec.rubyforge_project = "prawn"
  spec.add_dependency('pdf-reader', '>=0.8.1')
  spec.homepage = "http://"
  spec.description = <<END_DESC
  Howrah-Prawn is a Prawn sibling.
END_DESC
end
