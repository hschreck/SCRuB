Gem::Specification.new do |s|
  s.name        = 'scrubdeku'
  s.version     = '0.2.1'
  s.date        = '2017-03-30'
  s.summary     = "A gem used to work with the SellerCloud SOAP API"
  s.description = "Simplifies interaction with the SellerCloud SOAP API to enable faster development of integrations."
  s.authors     = ["Harold Schreckengost"]
  s.email       = 'harold@haroldmschreckengost.com'
  s.files       = ["lib/scrubdeku.rb"]
  s.homepage    =
    'https://github.com/hschreck/scrubdeku'
  s.license       = 'MIT'
  s.add_runtime_dependency 'savon', '~> 2.0', '>=2.0'
end
