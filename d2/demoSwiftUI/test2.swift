//
//  test2.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/9/1.
//

import SwiftUI
import Kingfisher

struct test2: View {
    var body: some View {
        
        
        HStack (alignment: .top){
  
            LazyVStack {
                KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png"))
                    .resizable()
                    .frame(width: 300, height: 300)
                    .background(Color.black)
                    Text("ffdasfads")
                        .background(Color.gray)
                        .font(.title)
                    
                    Spacer()
                    HStack (alignment: .center){
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.blue))
                            .overlay(
                                Text("ffjaldjfslk")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                
                                
                            )
                            .frame(width: 100, height: 40)
                            .padding(.horizontal,3)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.blue))
                            .overlay(
                                Text("ffjaldjfslk")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.white)
                                
                                
                            )
                            .frame(width: 100, height: 40)
                            .padding(.horizontal,3)
                    }
                    HStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray)
                            .overlay(
                                Text("Weight 22  Height 33")
                                    
                            ).frame(width: 200, height: 20, alignment: .center)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray)
                            .overlay(
                                Text("Weight 22  Height 33")
                                    
                            ).frame(width: 200, height: 20, alignment: .center)
                    }
                
                VStack {
                    Text("pokeVM.t textt.flavor_text.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.tex.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.tex")
                
                 
                }.frame(minHeight: 100, idealHeight: 100).background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
                
                
                LazyVStack (alignment: .leading){
                    
                }.padding()
                
                
 
               
            }
        
        }
        
        .background(Color.red)
        
        
        

    }
}

struct test2_Previews: PreviewProvider {
    static var previews: some View {
        test2()
    }
}
