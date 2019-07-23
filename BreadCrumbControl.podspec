Pod::Spec.new do |s|
  s.name = 'BreadCrumbControl'
  s.version = '0.2.0'
  s.swift_versions = ['5.0']
  s.license = 'BSD'
  s.summary = 'BreadCrumb Control (Swift)'
  s.homepage = 'https://github.com/apparition47/BreadCrumbControl'
  s.authors = { 'Philippe Kersalé' => 'phil.kersale@free.fr' }
  s.source = { :git => 'https://github.com/apparition47/BreadCrumbControl.git', :tag => s.version }

  s.ios.deployment_target = '10.0'

  s.source_files = 'BreadCrumb Control/BreadCrumb Control/*.swift'
  s.resources = "BreadCrumb Control/BreadCrumb.{xcassets}"
end
