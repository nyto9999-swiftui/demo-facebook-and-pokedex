//
//  PokemonInfo.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/29.
//

import SwiftUI
import Kingfisher

struct PokemonDetailView: View {
    @StateObject var pokeVM = PokemonVM()
    
    var name:String
    var index: String
    var body: some View {
        ZStack {
            Color.pokeWhite.edgesIgnoringSafeArea(.all)
            
            HStack (alignment: .top) {
                LazyVStack {
               
                    HStack {
                        KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokeVM.pokemonDetails.id).png"))
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
                   
             
                  
                    // name
                    HStack {
                        Text(name.capitalized)
                            .font(.largeTitle).bold()
                            .foregroundColor(Color.pokeRed)
                        
                    }
                 
                    // types
                    HStack (alignment: .center){
                        
                        ForEach(pokeVM.pokemonDetails.types, id: \.self) { poke in
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(pokeVM.backgroundColor(forType: poke.type.name)).opacity(0.7))
                                .overlay(
                                    Text(poke.type.name.capitalized)
                                        .font(.subheadline).bold()
                                        .foregroundColor(.white)

                                )
                                .frame(width: 100, height: 40)
                                .padding(.horizontal,3)
                        }
                        
                    }
                    
                    //weight height'
                    
                    HStack {
                      
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.7))
                            .overlay(
                                Text("Weight \(String(pokeVM.pokemonDetails.weight))  Height \(String(pokeVM.pokemonDetails.height))")
                                    .foregroundColor(Color.black)
                                     
                            ).frame(width: 180, height: 27, alignment: .center)
                  
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.yellow.opacity(0.7))
                            .overlay(
                               
                                Text("Catch Rate:")
                                        .foregroundColor(Color.black)
         
                            ).frame(width: 135, height: 27, alignment: .center)
                        }
                    
                
                    
                    
                    //txt
                    HStack(alignment: .top) {
                        Text(pokeVM.text.flavor_text)
                            .foregroundColor(Color.black.opacity(0.8)).bold()
                            
                    
                    }.frame(minHeight: 40, idealHeight: 100)
                    
                    //stats
                    LazyVStack () {
                        ForEach(pokeVM.pokemonDetails.stats, id:\.self) { stat in
                            
                             HStack () {
                                GeometryReader  { g in
                                    VStack (alignment: .leading) {
                                       HStack () {
                                           Text(pokeVM.statShortString(forType: stat.stat.name))
                                            .font(.system(size: g.size.height > g.size.width ? g.size.width * 0.9: g.size.height * 0.9))
                                            .foregroundColor(.black).bold()
                                           Text(String(stat.base_stat))
                                            .font(.system(size: g.size.height > g.size.width ? g.size.width * 0.75: g.size.height * 0.75))
                                            .foregroundColor(.black).bold()
                                           
                                       }
                                   }
                                }
                               

                                ZStack (alignment: .leading){
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white).opacity(0.5)
                                        .frame(width: 300)
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.pokeRed)
                                            .frame(width: CGFloat(stat.base_stat)*2)
                                            

                                }.frame(minHeight: 20, maxHeight: 20)
                            }
                            }
                    }.padding()
                    Spacer()
                 
                }
                
               
       
                Spacer()}.onAppear{
            pokeVM.getPokemonDetail(name: name) { detail in
                self.pokeVM.pokemonDetails = detail
            }
                    pokeVM.getPokemonMoreDetail(index: Int(index) ?? 1) { moreDetail in
                        self.pokeVM.text = moreDetail
            }
            
        }
       
        
    }
    
}
 
}
