//
//  Model.swift
//  connect4
//
//  Created by Nanway Chen on 29/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation

struct FileInfo : Hashable {
    var name : String
    var ext : String
}

enum GameType  {
    case Human
    case AI(String)
    case Random
}

extension GameType : CustomStringConvertible {
    var description: String {
        switch self {
        case .Human:
            return "Human"
        case .AI(let type):
            return type
        case .Random:
            return "Random Player"
        }
    }
}

struct ModelJsonData : Codable {
    var modelName : String
    var modelPath : String
    var type : String
}

class DataModel {
    private static var dataModel : DataModel?
    
    static let redPathPrefix = "red_brain"
    static let bluPathPrefix = "blu_brain"
    
    static func getDataModel() -> DataModel {
        if let singleton = DataModel.dataModel {
            return singleton
        } else {
            let newSingleTon = DataModel()
            return newSingleTon
        }
    }
    
    var modelNameToPath = [String : FileInfo]()
    var redGameTypes = [GameType]()
    var bluGameTypes = [GameType]()
    private init() {
        let json = DataModel.readJSONFromFile(fileName: "modelInfo")
        do {
            let decoder = JSONDecoder()
            let jsonDataArray = try decoder.decode([ModelJsonData].self, from: json)
            
            redGameTypes.append(.Human)
            bluGameTypes.append(.Human)
            bluGameTypes.append(.Random)
            redGameTypes.append(.Random)
            
            for item in jsonDataArray {
                if (item.type == "Both") {
                    modelNameToPath[item.modelName] = FileInfo(name: item.modelPath, ext: "tflite")
                    redGameTypes.append(.AI(item.modelName))
                    bluGameTypes.append(.AI(item.modelName))
                } else if (item.type == "Red") {
                    modelNameToPath[item.modelName] = FileInfo(name: item.modelPath, ext: "tflite")
                    redGameTypes.append(.AI(item.modelName))
                } else {
                    modelNameToPath[item.modelName] = FileInfo(name: item.modelPath, ext: "tflite")
                    bluGameTypes.append(.AI(item.modelName))
                }

            }
        } catch {
            print(error.localizedDescription)
            exit(EXIT_FAILURE)
        }
        DataModel.dataModel = self
    }
    
    private static func readJSONFromFile(fileName: String) -> Data {
        let json: Data
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                json = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            } catch {
                print("ya fucked up couldn't convert json to data")
                exit(EXIT_FAILURE)
            }
        } else {
            exit(EXIT_FAILURE)
        }
        return json
    }
}
