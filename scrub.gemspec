Gem::Specification.new do |s|
  s.name        = 'scrubdeku'
  s.version     = '0.1.0'
  s.date        = '2017-03-23'
  s.summary     = "A gem used to work with the SellerCloud SOAP API"
  s.description = "Simplifies interaction with the SellerCloud SOAP API to enable faster development of integrations.  Uses SCRuB name because author is confused."
  s.authors     = ["Harold Schreckengost"]
  s.email       = 'harold@haroldmschreckengost.com'
  s.files       = ["lib/SCRuB.rb"]
  s.homepage    =
    'https://github.com/hschreck/SCRuB'
  s.license       = 'MIT'
  s.add_runtime_dependency 'savon', '~> 2.0', '>=2.0'
end
