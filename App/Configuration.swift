//
//  Configuration.swift
//  App
//
//  Created by x on 7/11/2022.
//

import Foundation


struct ConfigInfo: Decodable {
}

class Config : ObservableObject {
    private static var _shared: Config = {
        return Config(filename: Constant.ConfigurationFilename)
    }()
    class func shared() -> Config {
        return self._shared
    }
    
    var info:ConfigInfo
    
    private init(filename: String) {
        self.info = Config.load(forResource: filename)
    }
    
    private static func load(forResource: String) -> ConfigInfo {
        /// load TX informations from json
        let url = Bundle.main.url(forResource: forResource, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let config = try! JSONDecoder().decode(ConfigInfo.self, from: data)
        return config
    }
}
