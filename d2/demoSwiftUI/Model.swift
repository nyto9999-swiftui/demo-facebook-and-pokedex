//
//  Model.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/24.
//

import Foundation
import UIKit


var scroll_Tabs = ["","Gen", "Type"]
var stats = ["HP", "ATK", "DEF", "SA", "SD", "SP"]
let generation = ["1","2","3","4","5","6","7","8"]
let typeArray = ["bug","fire","dragon","electric","fighting", "ice", "normal", "dark", "fairy", "flying", "ghost", "grass", "ground", "psychic", "poison", "rock", "water", "steel"]

// list all pokemons
struct PokemonArray: Hashable, Codable {
    // let count: Int?
    // let next: String? "https://pokeapi.co/api/v2/pokemon?offset=3&limit=3"
    // let previous: String?
    let results: [Pokemon]
}


//type
struct pokemonTypeArray: Hashable, Codable {
    let pokemon: [Pokemons]
}
    struct Pokemons: Hashable, Codable {
        let pokemon: Pokemon
        
    }

//gen
struct pokemonGenArray: Hashable, Codable {
    let pokemon_species: [Pokemon]
}


struct Pokemon: Hashable, Codable {
    let name: String
    let url: String
}


//specific pokemon info
struct PokemonDetails: Hashable, Codable {
    let id: Int
    let types : [Type]
    var height: Int = 0
    var weight: Int = 0
    let stats : [Stat]
    let abilities : [Ability]
    let forms : [Form]
    
    init() {
        id = 0
        height = 0
        weight = 0
        types = []
        stats = []
        abilities = []
        forms = []
    }
}

struct Ability: Hashable, Codable {
    let ability: AbilityInfo
}

struct AbilityInfo: Hashable, Codable {
    let name : String
    let url : String
}

struct Type: Hashable, Codable {
    let type: TypeInfo
}

struct TypeInfo: Hashable, Codable {
    let name : String
    let url : String
}
struct Stat: Hashable, Codable {
    let base_stat : Int
    let stat : StatInfo
}

struct StatInfo: Hashable, Codable {
    let name : String
    let url : String
}

struct Form: Hashable, Codable {
    let url : String
}


//species/int

//捕捉率

struct PokemonMoreDetail: Hashable, Codable {
    var capture_rate : Int
    var flavor_text_entries : [Flavor_text_entry]
    init() {
        capture_rate = 0
        flavor_text_entries = []
    }
}

struct Flavor_text_entry: Hashable, Codable {
    var flavor_text : String
 
    init() {
        flavor_text = ""
      
    }
}

struct MoreInfo: Hashable, Codable {
    var capture_rate : Int
    var flavor_text : String
    
    init() {
        flavor_text = ""
        capture_rate = 0
    }
}
