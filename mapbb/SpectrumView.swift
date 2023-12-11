import SwiftUI
import MapboxMaps
import Charts

struct PopupView: View {
    @Binding var isPresent: Bool
    var Lat:Double
    var Lon:Double
    
    var body: some View {
        VStack {
            //緯度の絶対値を取得(2桁以下の時"0"を追加)
            let smallLat: String = String(format: "%02d", abs(Int(Lat)))
            let bigLat: String = String(format: "%02d", abs(Int(Lat))+1)

            //経度の絶対値を取得
            let Long: String = String(format: "%03d", abs(Int(Lon)))
            //西0~180度の時、360~180度に変換(3桁以下の場合"0"追加する)
            var smallLon: String {
                if(String(Lon).contains("-") == true) {
                    return String(format: "%03d", 359-abs(Int(Lon)))
                }else{
                    return Long
                }
            }
            let bigLon: String = String(format: "%03d", Int(smallLon)!+1)

            //url 作成
            var url:String {
                if(String(Lat).contains("-") == true && smallLat == "00") {
                    return "https://data.darts.isas.jaxa.jp/pub/pds3/sln-l-mi-5-map-v3.0/lon"+smallLon+"/data/MI_MAP_03_N00E"+smallLon+"S01E"+bigLon+"SC.img"
                }else if(String(Lat).contains("-") == false) {
                    return "https://data.darts.isas.jaxa.jp/pub/pds3/sln-l-mi-5-map-v3.0/lon"+smallLon+"/data/MI_MAP_03_N"+bigLat+"E"+smallLon+"N"+smallLat+"E"+bigLon+"SC.img"
                }else{
                    return "https://data.darts.isas.jaxa.jp/pub/pds3/sln-l-mi-5-map-v3.0/lon"+smallLon+"/data/MI_MAP_03_S"+smallLat+"E"+smallLon+"S"+bigLat+"E"+bigLon+"SC.img"
                }
            }
            
            Text(String(Lat))
            Text(String(Lon))
//            Text(smallLat)
//            Text(bigLat)
//            Text(smallLon)
//            Text(bigLon)
            Text(url)
            
            let x_data = [414, 749, 901, 950, 1001, 1000, 1049, 1248, 1548]
            let x_scale_data = [415, 750, 900, 950, 1000, 1050, 1250, 1550]
            
            // 緯度の小数点以下
            let LatRadix:Double = {
                if(Lat - Double(Int(Lat))<0){
                    return (Lat - Double(Int(Lat))) * -1.0
                }else{
                    return Lat - Double(Int(Lat))
                }
            }()
            // 経度の小数点以下
            let LonRadix:Double = {
                if(Lon - Double(Int(Lon))<0){
                    return (Lon - Double(Int(Lon))) * -1.0
                }else{
                    return Lon - Double(Int(Lon))
                }
            }()

            // 横何個目か調査(1を2048分割した配列にLonRadixを入れて小さい順にソート)
            let LonArr: [Double] = {
                var array:Array<Double> = [0]
                let all = 0.00048828125
                for i in 1..<2049 {
                    array += [all*Double(i)]
                }
                array += [LonRadix]
                array.sort{ $0 < $1 }
                return array
            }()
                                
            let index1 = LonArr.firstIndex(of: LonRadix)
            let LonIndex = index1!-1
                                
            // 縦何個目か調査(1を2048分割した配列にLatRadixを入れて小さい順にソート)
            let LatArr: [Double] = {
                var array:Array<Double> = [0]
                let all = 0.00048828125
                for i in 1..<2049 {
                    array += [all*Double(i)]
                }
                array += [LatRadix]
                array.sort{ $0 < $1 }
                return array
            }()
                                
            let index2 = LatArr.firstIndex(of: LatRadix)
            let LatIndex = index2!-1
                                
            //何バイト目か抽出
            let ByteNumber: Int = {
                if(String(Lat).contains("-")){
                    return 2048*LatIndex+LonIndex   // 南緯の場合(2048*LatIndex+LonIndex)
                }else {
                    return 2048*(2047-LatIndex)+LonIndex//北緯の場合:2048*(2047-LatIndex)+LonIndex
                }
            }()
            
            let byteNumber: Int = ByteNumber-1
            
//            Text(String(LonIndex))
//            Text(String(LatIndex))
//            Text(String(byteNumber))
               
                            
            //バイナリデータ読み込み
            let img: Array<Double> = {
                                
                let dataURL = URL(string: url)!
                var binaryData = Data();
                do {
                    binaryData = try Data(contentsOf: dataURL, options: [])
                } catch {
                    print("Failed to read the file.")
                }
                //        URLSession.shared.dataTask(with: dataURL) { (data, response, error) in
                //              // Error handling...
                //              guard let binaryData = data else { return }
                //
                //              DispatchQueue.main.async {
                //              }
                //            }.resume()
                    
                                
                let i16array = binaryData.withUnsafeBytes{UnsafeBufferPointer<Int16>(start: $0, count: binaryData.count/2).map(Int16.init(bigEndian:))}

                                
                let spectraArray = [Double(i16array[8388608+byteNumber])*0.002, Double(i16array[12582912+byteNumber])*0.002, Double(i16array[16777216+byteNumber])*0.002, Double(i16array[20971520+byteNumber])*0.002, Double(i16array[25165824+byteNumber])*0.002, Double(i16array[29360128+byteNumber])*0.002, Double(i16array[33554432+byteNumber])*0.002, Double(i16array[37748736+byteNumber])*0.002, Double(i16array[41943040+byteNumber])*0.002]

                return spectraArray

                }()
                            
                        
                Chart {
                    LineMark(x: .value("Wavelength", x_data[0]), y: .value("Reflectance", img[0]))
                    PointMark(x: .value("Wavelength", x_data[0]), y: .value("Reflectance", img[0]))
                    LineMark(x: .value("Wavelength", x_data[1]),
                            y: .value("Reflectance", img[1]))
                    PointMark(x: .value("Wavelength", x_data[1]),
                            y: .value("Reflectance", img[1]))
                    LineMark(x: .value("Wavelength", x_data[2]),
                            y: .value("Reflectance", img[2]))
                    PointMark(x: .value("Wavelength", x_data[2]),
                            y: .value("Reflectance", img[2]))
                    LineMark(x: .value("Wavelength", x_data[3]),
                            y: .value("Reflectance", img[3]))
                    PointMark(x: .value("Wavelength", x_data[3]),
                            y: .value("Reflectance", img[3]))
                    LineMark(x: .value("Wavelength", x_data[4]),
                            y: .value("Reflectance", img[4]))
                    PointMark(x: .value("Wavelength", x_data[4]),
                            y: .value("Reflectance", img[4]))
                    LineMark(x: .value("Wavelength", x_data[5]),
                            y: .value("Reflectance", img[5]))
                    PointMark(x: .value("Wavelength", x_data[5]),
                            y: .value("Reflectance", img[5]))
                    LineMark(x: .value("Wavelength", x_data[6]),
                            y: .value("Reflectance", img[6]))
                    PointMark(x: .value("Wavelength", x_data[6]),
                            y: .value("Reflectance", img[6]))
                    LineMark(x: .value("Wavelength", x_data[7]),
                            y: .value("Reflectance", img[7]))
                    PointMark(x: .value("Wavelength", x_data[7]),
                            y: .value("Reflectance", img[7]))
                    LineMark(x: .value("Wavelength", x_data[8]),
                            y: .value("Reflectance", img[8]))
                    PointMark(x: .value("Wavelength", x_data[8]),
                            y: .value("Reflectance", img[8]))
                    }
            //ラベルの位置また注意される
                    .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 0) {
                        Text("Wavelength[nm]")
                        .font(.title3)
                        .foregroundColor(.purple)
                    }
                    .chartYAxisLabel(position: .top, alignment: .topTrailing, spacing: 1) {
                        Text("Reflectance[%]")
                        .font(.title3)
                        .foregroundColor(.purple)
                    }
                    .chartXAxis() {
                        AxisMarks(preset: .aligned, position: .bottom, values: x_scale_data)
            //            AxisMarks(preset: .aligned, position: .top, values: bb)
                    }
                    .chartXScale(domain: 414 ... 1600)
                    //https://tech.nri-net.com/entry/swiftui_chartgraph
                    .padding(EdgeInsets(
                        top: 3,
                        leading: 100,
                        bottom: 0,
                        trailing: 105
                    ))
                            
            let o1 = (img[0]/img[1])-0.208
            let o2 = img[1]+0.108
            let o3 = atan(o1/o2)
            let o4 = o3 * (180.0 / .pi)
            
            let fe1 = (img[3]/img[1])-1.25
            let fe2 = img[1]+0.037
            let fe3 = atan(fe1/fe2)
            let fe4 = fe3 * (180.0 / .pi)
            
            Text(String(fe1))
            Text(String(fe2))
            Text(String(fe3))
//            Text(String(o1))
//            Text(String(o2))
//            Text(String(o3))
            
            Text("θTi = " + String(o4))   //になることある？
            Text("θFe = " + String(fe4))   //になることある？

            
            Text("R415 = "+String(img[0]))
            Text("R750 = "+String(img[1]))
            Text("R950 = "+String(img[3]))

            //              Text(String(atan(Double(0.03107)) * (180.0 / .pi)))

            Button(action: {
                withAnimation {
                    isPresent = false
                }
            }, label: {
                Text("Close")
            })
        }
    }
}
