Pod::Spec.new do |s|
    s.name                  = "RxDBSync"
    s.version               = "0.2.0"
    s.summary               = "Provides convenient sync JSON with Core Data via reactive extensions"
    s.description           = <<-DESC
    Provides convenient sync JSON with Core Data via reactive extensions:
    ```let dataprovider = CoredataConfigurator.shared.queryProvider
    
    Observable.just([rawSpider, rawCap, rawHalk])
      .mapDictionaryToArrayEntities(HeroEntity.self, databaseMapper: dataprovider)
      .subscribe(
        onNext: { _ in
          print("success")
      },
        onError: { e in
          print("error: \(e)")
      }).disposed(by: bag)```
    DESC

    s.homepage              = "https://github.com/alobanov/RxDatabaseSync"
    s.license               = { :type => "MIT", :file => "LICENSE.md" }
    s.author                = { "Lobanov Aleksey" => "lobanov.aw@gmail.com" }
    s.source                = { :git => "git@github.com:alobanov/RxDatabaseSync.git", :tag => s.version.to_s }
    s.social_media_url      = "https://twitter.com/alobanov"

    s.ios.deployment_target = '9.0'

    s.source_files = 'Sources/**/*'

    s.frameworks            = 'UIKit', 'CoreData'

    s.dependency 'RxSwift', '~> 3'
    s.dependency 'RxCocoa', '~> 3'
    s.dependency 'SwiftyJSON'
    s.dependency 'ObjectMapper'
    s.dependency 'Sync', '3.3.0'
end
