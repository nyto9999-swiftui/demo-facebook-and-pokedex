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
    
    @Published var pokemons = [Pokemon]()
    
    @Published var typeDict = [String:[Pokemons]]()
    @Published var genDict = [String:[Pokemon]]()
    
    @Published var pokemonDetails = PokemonDetails()
    @Published var pokemonMoreDetails = PokemonMoreDetail()
    @Published var text = Flavor_text_entry()
    @Published var moreInfo = MoreInfo()
//    @Published var type = [Pokemons]()
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
                        self?.typeDict["\(type)"] = model.pokemon
                        print("Type \(type) : \((self?.typeDict["\(type)"]?.count)!)")
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
                self.moreInfo.capture_rate = moreDetail.capture_rate
                self.moreInfo.flavor_text = editedText
                completion(self.text)
            }

        }
        task.resume()

    }
    
    public func backgroundColor(forType type: String) -> UIColor {
        switch type {
            case "fire": return UIColor(Color(hex: "#F08030"))
            case "poison": return UIColor(Color(hex: "#A040A0"))
            case "water": return UIColor(Color(hex: "#6890F0"))
            case "electirc": return UIColor(Color(hex: "#F8D030"))
            case "psychic": return UIColor(Color(hex: "#F85888"))
            case "normal": return UIColor(Color(hex: "#A8A878"))
            case "grass": return UIColor(Color(hex: "#78C850"))
            case "bug": return UIColor(Color(hex: "#A8B820"))
            case "ground": return UIColor(Color(hex: "#E0C068"))
            case "fairy": return UIColor(Color(hex: "#EE99AC"))
            case "fighting": return UIColor(Color(hex: "#C03028"))
            case "rock": return UIColor(Color(hex: "#B8A038"))
            case "ghost": return UIColor(Color(hex: "#705898"))
            case "ice": return UIColor(Color(hex: "#98D8D8"))
            case "dragon": return UIColor(Color(hex: "#7038F8"))
            
            default:
                return .systemIndigo
        }
    }
    
   
    
    public func statShortString(forType type: String) -> String {
        switch type {
            case "hp": return "HP  "
            case "attack": return "ATK"
            case "special-attack": return "SA  "
            case "special-defense": return "SD  "
            case "defense": return "DEF"
            case "speed": return "SP  "
            
            default:
                return ""
        }
    }
    
}



