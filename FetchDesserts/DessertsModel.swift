import Foundation

struct Dessert: Codable, Hashable, Identifiable {
    let id: String?
    let name: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case imageURL = "strMealThumb"
        case id = "idMeal"
    }
}

struct DessertResponse: Codable {
    let desserts: [Dessert]

    enum CodingKeys: String, CodingKey {
        case desserts = "meals"
    }
}

struct DetailResponse: Codable {
    let details: [DessertDetails]

    enum CodingKeys: String, CodingKey {
        case details = "meals"
    }
}

struct DessertDetails: Codable {
    let id: String?
    let name: String
    let imageURL: String
    let instructions: String

    var ingredients: [(ingredient: String, measurement: String)] = []

    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case imageURL = "strMealThumb"
        case instructions = "strInstructions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.imageURL = (try? container.decode(String.self, forKey: .imageURL)) ?? ""
        self.instructions = (try? container.decode(String.self, forKey: .instructions)) ?? ""

        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempIngredients: [String: String] = [:]
        var tempMeasurements: [String: String] = [:]

        for key in dynamicContainer.allKeys {
            if key.stringValue.hasPrefix("strIngredient"), let ingredient = try dynamicContainer.decodeIfPresent(String.self, forKey: key), !ingredient.isEmpty {
                let index = key.stringValue.replacingOccurrences(of: "strIngredient", with: "")
                tempIngredients[index] = ingredient
            }
            if key.stringValue.hasPrefix("strMeasure"), let measurement = try dynamicContainer.decodeIfPresent(String.self, forKey: key), !measurement.isEmpty {
                let index = key.stringValue.replacingOccurrences(of: "strMeasure", with: "")
                tempMeasurements[index] = measurement
            }
        }

        let sortedKeys = tempIngredients.keys.sorted(by: { Int($0)! < Int($1)! })
        for key in sortedKeys {
            let ingredient = tempIngredients[key] ?? ""
            let measurement = tempMeasurements[key] ?? ""
            ingredients.append((ingredient, measurement))
        }
    }
    
    var instructionsWithBreak: String {
        return instructions.replacingOccurrences(of: "\n", with: "\n\n")
    }

    var joinedIngredientsMeasurements: String {
        var result = ""
        for (ingredient, measurement) in ingredients {
            result.append("\(measurement) \(ingredient)\n")
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
