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
    
    var body: some View {

        VStack  (alignment: .center){
            
            KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokeVM.pokemonDetails.id).png"))
                .resizable()
                .frame(width: 300, height: 300)
                .background(Color.red)
            
            
            // 名稱 fix
            Text("名稱: \(name)")
                .background(Color.gray)
            
            
            // 資訊
            //                 ForEach(pokeVM.pokemonDetails.forms, id: \.self) { form in
            //                     Text(form.url)
            //                 }
            HStack (alignment: .center){
                
                ForEach(pokeVM.pokemonDetails.types, id: \.self) { poke in
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(pokeVM.backgroundColor(forType: poke.type.name)).opacity(0.7))
                        .overlay(
                            Text(poke.type.name)
                                .font(.subheadline).bold()
                                .foregroundColor(.white)
                            
                            
                        )
                        .frame(width: 100, height: 40)
                        .padding(.horizontal,3)
                    
                    
                }
                
            }
            
            //身高體重
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray)
                .overlay(
                    Text("Weight \(String(pokeVM.pokemonDetails.weight))  Height \(String(pokeVM.pokemonDetails.height))")
                        
                ).frame(width: 300, height: 40, alignment: .center)
                
            
      
            
            
            //個體
//            ForEach(pokeVM.pokemonDetails.stats, id: \.self) { stat in
//
//
//
//                HStack {
//                    Text(stats["\(stat.stat.name)"]!)
//                    Text(String(stat.base_stat))
//                    Spacer()
//                }
//
//            }
            HStack (alignment: .top, spacing: 6) {
                VStack (alignment: .leading, spacing: 15){
                    ForEach(0..<stats.count, id:\.self) { index in
                        VStack (alignment: .leading, spacing: 6) {
                            Text(stats[index])
                        }
                    }
                }
                VStack (alignment: .leading, spacing: 15){
                    ForEach(pokeVM.pokemonDetails.stats, id:\.self) { stat in
                        VStack (alignment: .leading, spacing: 6) {
                            Text(String(stat.base_stat))
                        }
                    }
                
                }
                VStack (alignment: .leading, spacing: 15){
                    ForEach(pokeVM.pokemonDetails.stats, id:\.self) { stat in
                        VStack (alignment: .leading, spacing: 6) {
                            ZStack (alignment: .leading){
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.red)
                                    .frame(width: 300)
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.green)
                                        .frame(width: CGFloat(stat.base_stat)*2)

                            }
                        }
                        
                    }
                }
                Spacer()
            }
           
            
     
            
            
            
      
            
            //特性
            ForEach(pokeVM.pokemonDetails.abilities, id: \.self) { abilities in
                Text(abilities.ability.name)
            }
            
            ForEach(pokeVM.pokemonMoreDetails.flavor_text_entries, id: \.self) { detail in
                Text(detail.flavor_text)
            }
            
            Text(pokeVM.text.flavor_text)
            
        }
        .background(Color.blue)
        .frame(
            maxHeight: .infinity,
            alignment: .topLeading)
        .onAppear{
            pokeVM.getPokemonDetail(name: name) { detail in
                self.pokeVM.pokemonDetails = detail
            }
            pokeVM.getPokemonMoreDetail(index: 1) { moreDetail in
                self.pokeVM.text = moreDetail
            }
            
        }
 
        //        .background(Color(pokeVM.backgroundColor(forType: pokeVM.pokemonDetails.types[0].type.name)))
        
    }
    
}

//struct PokemonDetailView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        PokemonDetailView(pokeName: "", dict: PokemonByGen)
//    }
//}
