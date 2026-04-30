#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint on_device_ai.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'on_device_ai'
  s.version          = '0.1.1'
  s.summary          = 'Cross-platform Flutter plugin for on-device AI inference using Apple frameworks (iOS) and TensorFlow Lite (Android).'
  s.description      = <<-DESC
A cross-platform Flutter plugin that provides a unified Dart API for running AI
inference entirely on-device, with no internet connection required.

On iOS it leverages Apple's built-in NaturalLanguage (sentiment analysis) and
Vision (image classification) frameworks. On Android it uses TensorFlow Lite
with a bundled MobileNet or MobileBERT model.
                       DESC
  s.homepage         = 'https://github.com/albertstany-tech/onDevice_AI_Assistant_SDK'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Albert Stany' => 'albertstany.tech@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'

  # System frameworks used for on-device AI — no third-party dependencies.
  s.frameworks = 'NaturalLanguage', 'Vision', 'CoreML'
end
