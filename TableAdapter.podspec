Pod::Spec.new do |s|
  s.name         = "TableAdapter"
  s.version      = "0.0.1"
  s.summary      = "A drop in replacement for UITableViewDataSource and UITableViewDelegate"
  s.description  = <<-DESC
                   This library is meant to provide a model-based approach for configuring table views.
                   It allows a for displaying multiple cell classes in a section, dynamic sizing, and easy insertion/deletion.
                   DESC
  s.homepage     = "http://github.com/Present-Inc/TableAdapter"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "Justin Makaila" => "justinmakaila@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "http://github.com/Present-Inc/TableAdapter.git", :tag => "0.0.1" }
  s.source_files  = "TableAdapter/*.{h,swift}"
  s.requires_arc = true
end
