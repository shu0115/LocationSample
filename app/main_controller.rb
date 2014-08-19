# class MainController < UIViewController
#   include MapKit

#   # ステータスバーを非表示にします
#   def prefersStatusBarHidden
#     true
#   end

#   def viewDidLoad
#     super
#     view.backgroundColor = UIColor.whiteColor

#     # デフォルトは東京駅の位置
#     # 緯度: 35.681382 経度: 139.766084
#     @map = MapView.new.tap do |m|
#       m.frame = view.frame
#       m.region = CoordinateRegion.new([35.681382, 139.766084], [3.1, 3.1])
#     end
#     view.addSubview(@map)
#   end
# end

# class MainController < UIViewController
#   include MapKit
#   # ステータスバーを非表示にします
#   def prefersStatusBarHidden
#     true
#   end
#   def viewDidLoad
#     super
#     view.backgroundColor = UIColor.whiteColor
#     current = UIButton.buttonWithType(UIButtonTypeSystem).tap do |b|
#       b.setTitle('現在位置', forState:UIControlStateNormal)
#       b.addTarget(self, action:'get_location:', forControlEvents:UIControlEventTouchUpInside)
#       b.frame = [[0, self.view.frame.size.height - 44], [80, 44]]
#     end
#     view.addSubview(current)
#     # デフォルトは東京駅の位置
#     # 緯度: 35.681382 経度: 139.766084
#     @map = MapView.new.tap do |m|
#       m.frame = [[0, 0], [self.view.frame.size.width, self.view.frame.size.height - 44]] # ボタンの縦幅分、地図を小さくしている
#       m.delegate = self # 追加
#       m.region = CoordinateRegion.new([35.681382, 139.766084], [3.1, 3.1])
#     end
#     view.addSubview(@map)
#   end
#   def get_location(sender)
#     BW::Location.get_once do |location|
#       add_pin(location, '現在位置') if location.respond_to?(:coordinate)
#     end
#   end
#   def add_pin(location, title)
#     # 既にピンが表示されていたら一旦全部取り除く
#     @map.removeAnnotations(@map.annotations) if @map.annotations
#     annotation = MKPointAnnotation.new.tap do |an|
#       an.title = title
#       an.coordinate = location.coordinate
#     end
#     @map.addAnnotation(annotation)
#     # 地図の表示領域をピンが中心に来るように移動させる
#     @map.region = CoordinateRegion.new({:center => location.coordinate, :span => {:latitude_delta => 0.5, :longitude_delta => 0.5}})
#   end
#   # MKMapView のデリゲートメソッド
#   def mapView(mapView, viewForAnnotation:annotation)
#     MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:'pin').tap do |pi|
#       pi.animatesDrop = true
#       pi.canShowCallout = true
#     end
#   end
# end

class MainController < UIViewController
  include MapKit
  CURRENT = 1
  SAPPORO = 2
  TOKYO   = 3
  FUKUOKA = 4

  # ステータスバーを非表示にします
  def prefersStatusBarHidden
    true
  end

  def viewDidLoad
    super
    view.backgroundColor = UIColor.whiteColor

    current = UIButton.buttonWithType(UIButtonTypeSystem).tap do |b|
      b.tag = CURRENT
      b.setTitle('現在位置', forState:UIControlStateNormal)
      b.addTarget(self, action:'get_location:', forControlEvents:UIControlEventTouchUpInside)
      b.frame = [[0, self.view.frame.size.height - 44], [80, 44]]
    end
    view.addSubview(current)

    sapporo = UIButton.buttonWithType(UIButtonTypeSystem).tap do |b|
      b.tag = SAPPORO
      b.setTitle('札幌', forState:UIControlStateNormal)
      b.addTarget(self, action:'get_location:', forControlEvents:UIControlEventTouchUpInside)
      b.frame = [[80, self.view.frame.size.height - 44], [80, 44]]
    end
    view.addSubview(sapporo)

    tokyo = UIButton.buttonWithType(UIButtonTypeSystem).tap do |b|
      b.tag = TOKYO
      b.setTitle('東京', forState:UIControlStateNormal)
      b.addTarget(self, action:'get_location:', forControlEvents:UIControlEventTouchUpInside)
      b.frame = [[160, self.view.frame.size.height - 44], [80, 44]]
    end
    view.addSubview(tokyo)

    fukuoka = UIButton.buttonWithType(UIButtonTypeSystem).tap do |b|
      b.tag = FUKUOKA
      b.setTitle('福岡', forState:UIControlStateNormal)
      b.addTarget(self, action:'get_location:', forControlEvents:UIControlEventTouchUpInside)
      b.frame = [[240, self.view.frame.size.height - 44], [80, 44]]
    end
    view.addSubview(fukuoka)

    # デフォルトは東京駅の位置
    # 緯度: 35.681382 経度: 139.766084
    @map = MapView.new.tap do |m|
      m.frame = [[0, 0], [self.view.frame.size.width, self.view.frame.size.height - 44]]
      m.delegate = self
      m.region = CoordinateRegion.new([35.681382, 139.766084], [3.1, 3.1])
    end
    view.addSubview(@map)
  end

  def get_location(sender)
    @geocoder ||= CLGeocoder.new
    case sender.tag
    when CURRENT
      BW::Location.get_once do |location|
        add_pin(location, '現在位置') if location.respond_to?(:coordinate)
      end
    when SAPPORO, TOKYO, FUKUOKA
      title = sender.titleForState(UIControlStateNormal)
      @geocoder.geocodeAddressString(title,
        completionHandler:lambda {|place, error|
          add_pin(place[0].location, title) if place.count > 0
        }
      )
    end
  end

  def add_pin(location, title)
    @map.removeAnnotations(@map.annotations) if @map.annotations
    annotation = MKPointAnnotation.new.tap do |an|
      an.title = title
      an.coordinate = location.coordinate
    end
    @map.addAnnotation(annotation)
    @map.region = CoordinateRegion.new({:center => location.coordinate, :span => {:latitude_delta => 0.5, :longitude_delta => 0.5}})
  end

  def mapView(mapView, viewForAnnotation:annotation)
    MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:'pin').tap do |pi|
      pi.animatesDrop = true
      pi.canShowCallout = true
    end
  end
end
