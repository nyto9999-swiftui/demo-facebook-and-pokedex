//
//  Model.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/24.
//

import Foundation
import UIKit

var scroll_Tabs = ["","Gen", "Type", "Strengh"]
let generation = ["1","2","3","4","5","6","7","8"]
let typeArray = ["bug","fire","dragon","electric","fighting", "ice", "normal", "dark", "fairy", "flying", "ghost", "grass", "ground", "psychic", "poison", "rock", "water", "steel"]

struct PokemonArray: Hashable, Codable {
    // let count: Int?
    // let next: String? "https://pokeapi.co/api/v2/pokemon?offset=3&limit=3"
    // let previous: String?
    let results: [PokemonInfo]
}
struct PokemonInfo: Hashable, Codable {
    var name : String
    var url : String // pokemon detail "https://pokeapi.co/api/v2/pokemon/2/"
    
    
}

struct PokemonDetail: Hashable, Codable {
    // let abilities
    // let form
    // let moves
    // type "grass" & "poison"
    let sprites : Img
}

struct Img: Hashable, Codable {
    var front_default : String
}



//type
struct pokemonTypeArray: Hashable, Codable {
    let pokemon: [Pokemons]
}
struct Pokemons: Hashable, Codable {
    let pokemon: Pokemon
}

struct Pokemon: Hashable, Codable {
    let name: String
    let url: String
}



//gen
struct pokemonGenArray: Hashable, Codable {
    let pokemon_species: [PokemonByGen]
}

struct PokemonByGen: Hashable, Codable {
    let name: String
    let url: String
}
