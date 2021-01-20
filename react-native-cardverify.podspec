require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-cardverify"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-cardverify
                   DESC
  s.homepage     = "https://github.com/getbouncer/react-native-cardverify"
  s.license      = "MIT"
  s.authors      = { "Stefano Suryanto, Adam Wushensky, Jaime Park" => "support@getbouncer.com" }
  s.platforms    = { :ios => "9.0", :tvos => "10.0" }
  s.source       = { :git => "https://github.com/getbouncer/react-native-cardverify.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "CardVerify", '~> 2.0.9'
end

