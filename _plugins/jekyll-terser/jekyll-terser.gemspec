Gem::Specification.new do |spec|
  spec.name          = "jekyll-terser"
  spec.version       = "0.2.0"
  spec.authors       = ["Roberto Beltran"]
  spec.summary       = "Jekyll plugin to minify JS using Terser"
  spec.homepage      = "https://github.com/RobertoJBeltran/jekyll-terser"
  spec.license       = "MIT"

  # 改用纯 Ruby 方式列出文件，不再依赖 Git 命令
  spec.files         = Dir.glob("{lib,exe}/**/*") + ["jekyll-terser.gemspec", "README.md", "LICENSE"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.0"
  spec.add_dependency "terser", ">= 1.0.2"
end
