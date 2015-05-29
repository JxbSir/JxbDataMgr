Pod::Spec.new do |s|

  s.name         = "JxbDataMgr"
  s.version      = "1.0"
  s.summary      = "本地小数据存储，使用json字符串保存数据，使用方便简单."
  s.homepage     = "https://github.com/JxbSir"
  s.license      = "Peter"
  s.author       = { "Peter" => "i@jxb.name" }
  s.requires_arc = true
  s.source       = { :git => "https://github.com/JxbSir/JxbDataMgr.git"  }
  s.source_files = "JxbDataMgr/JxbDataMgr/*.{h,m}"
  s.public_header_files = 'JxbDataMgr/JxbDataMgr/JxbDataMgr.h'
  s.frameworks   = 'UIKit'
s.dependency   'jastor'
s.dependency   'TouchJSON'
end
