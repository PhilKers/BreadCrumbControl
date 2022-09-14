Pod::Spec.new do |s|
  s.name = 'BreadCrumbControl'
  s.version = '0.3.0'
  s.swift_version = '5.0'
  s.license = 'BSD'
  s.summary = 'BreadCrumb Control (Swift)'
  s.homepage = 'https://github.com/apparition47/BreadCrumbControl'
  s.authors = { 'Philippe Kersalé' => 'phil.kersale@free.fr' }
  s.source = { :git => 'https://github.com/apparition47/BreadCrumbControl.git', :tag => s.version }
  s.platform = :ios, '10.0'
  s.source_files = 'Sources/BreadCrumbControl/*.swift'
  s.resource_bundles = {
    'BreadCrumbControl' => ['Sources/BreadCrumbControl/Resources/BreadCrumbControl.{xcassets}']
  }
end
