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
    @Published var pokemonDetails = PokemonDetails()
    @Published var pokemonMoreDetails = PokemonMoreDetail()
    @Published var text = Flavor_text_entry()
    
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
                        print("Type \(type) : \((self?.pokemonDict["\(type)"]?.count)!)")
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
                        
                        print("Genernatin \(gen) : \((self?.genDict["\(gen)"]?.count)!)")
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
    
    public func getPokemonDetail(name: String, completion: @escaping (PokemonDetails) -> ()) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name)") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print(error ?? "get detail error")
                return
            }
            
            let detail = try! JSONDecoder().decode(PokemonDetails.self, from: data)
            DispatchQueue.main.async {
                dump(detail)
                completion(detail)
            }
            
        }
        task.resume()
    }
//
    public func getPokemonMoreDetail(index: Int, completion: @escaping (Flavor_text_entry) -> ()) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(index)/") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print(error ?? "get more detail error")
                return
            }
            
            let moreDetail = try! JSONDecoder().decode(PokemonMoreDetail.self, from: data)
            DispatchQueue.main.async {
                dump(moreDetail)
                
                let editedText = moreDetail.flavor_text_entries[0].flavor_text.replacingOccurrences(of: "\n", with: " ")
                self.text.flavor_text = editedText
                completion(self.text)
            }

        }
        task.resume()

    }
    
    public func backgroundColor(forType type: String) -> UIColor {
        switch type {
            case "fire": return .systemRed
            case "poison": return .systemPurple
            case "water": return .systemBlue
            case "electirc": return .systemYellow
            case "psychic": return .systemPink
            case "normal": return .systemGray
            
            default:
                return .systemIndigo
        }
    }
    
}



