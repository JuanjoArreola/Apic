Pod::Spec.new do |s|
  s.name         = "Apic"
  s.version      = "1.2.1"
  s.summary      = "Apic is a library build on top of Alamofire that parses JSON API responses into swift objects"
  s.homepage     = "https://github.com/JuanjoArreola/Apic"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juanjo Arreola" => "juanjo.arreola@gmail.com" }

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/JuanjoArreola/Apic.git", :tag => "version_1.2.1" }
  s.source_files = "Apic/*.swift"
  s.resources    = "Apic/apic_properties.plist"

  s.requires_arc = true
  s.framework    = "SystemConfiguration"
  s.dependency "Alamofire", "~> 3.1.5"
end
