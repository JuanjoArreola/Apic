Pod::Spec.new do |s|
  s.name         = "Apic"
  s.version      = "5.1.1"
  s.summary      = "Apic is a library that parses JSON API responses into swift objects"
  s.homepage     = "https://github.com/JuanjoArreola/Apic"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Juanjo Arreola" => "juanjo.arreola@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/JuanjoArreola/Apic.git", :tag => "#{s.version}" }
  s.source_files = "Sources/*.swift"

  s.requires_arc = true
  s.ios.framework    = "SystemConfiguration"
  s.osx.framework    = "SystemConfiguration"
  s.tvos.framework    = "SystemConfiguration"

  s.dependency "AsyncRequest", "~> 2.2.0"

end
