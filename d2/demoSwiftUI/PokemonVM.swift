//
//  DatabaseManager.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/24.
//

import Foundation
import SwiftUI
import Kingfisher





class PokemonVM: ObservableObject {
    
    @Published var pokemons = [PokemonInfo]()
    @Published var type = [Pokemons]()
    @Published var pokemonDict = [String:[Pokemons]]()
    @Published var genDict = [String:[PokemonByGen]]()
    
    init() {
        
    
        // fectch pokemon by type
        getPokemonByType()
        getAllPokemon()
        getPokemonByGen()
        
        
        //fetch pokemon detail page and name
        
        
        
        
    }
    

    
    private func getPokemonByType() {
        
        for type in typeArray {
            guard let url = URL(string: "https://pokeapi.co/api/v2/type/\(type)") else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let model = try JSONDecoder().decode(pokemonTypeArray.self, from: data)
                    DispatchQueue.main.async {
                        self?.pokemonDict["\(type)"] = model.pokemon
                        print("pokemon by type : \(self?.pokemonDict["\(type)"]?.count)")
                    }
                    
                }catch {
                    print(error)
                }
            }
            task.resume()
        }
        
        
    }
    
    private func getPokemonByGen(){
        for gen in generation {
            guard let url = URL(string: "https://pokeapi.co/api/v2/generation/\(gen)") else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let model = try JSONDecoder().decode(pokemonGenArray.self, from: data)
                    DispatchQueue.main.async {
                        self?.genDict["\(gen)"] = model.pokemon_species
                        print("pokemon by gen : \(self?.genDict["\(gen)"]?.count)")
                    }
                }catch{
                    print(error)
                }
            }
            task.resume()
        }
        
    }
    
    private func getAllPokemon(){
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=897&offset=0") else {
            return
        }
        
        let task2 = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let limitAndOffset = try JSONDecoder().decode(PokemonArray.self, from: data)
                DispatchQueue.main.async {
                    self?.pokemons = limitAndOffset.results
                    
                }
            }
            catch {
                print(error)
            }
        }
        task2.resume()
    }
}


