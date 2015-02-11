Pod::Spec.new do |s|
  s.name         = "TableAdapter"
  s.version      = "0.0.1"
  s.summary      = "A short description of TableAdapter."
  s.description  = <<-DESC
                   A longer description of TableAdapter in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "http://github.com/Present-Inc/TableAdapter"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "Justin Makaila" => "justinmakaila@gmail.com" }
  s.platform     = :ios
  s.source       = { :git => "http://github.com/Present-Inc/TableAdapter.git", :tag => "0.0.1" }
  s.source_files  = "TableAdapter/*.{h,swift}"
  s.requires_arc = true
end
