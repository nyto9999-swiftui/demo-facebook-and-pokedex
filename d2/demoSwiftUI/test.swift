//
//  test.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/9/1.
//

import SwiftUI
import Kingfisher

struct test: View {
    var body: some View {
        NavigationView{
            
            VStack {
                ZStack (alignment: .top){
                    
                    KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png"))
                        .resizable()
                        .frame(width: 300, height: 300)
                        .background(Color.black)
                    
                    
                    VStack {
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
                        
     
                    }
                    
                    
                }.background(Color.red).frame(height:350)
                
                VStack {
                    Text("pokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_texflavor_textpokeVM.text.flavor_textpokeVM.text.flavor_flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_textpokeVM.text.flavor_text")
                }
                
                ForEach(0..<stats.count, id:\.self) { index in
                    HStack (alignment: .top) {
                        
                           
                                
                        VStack () {
                            Text(stats[index])
                            Text(stats[index])
                            
                        }
                           
                                
                        ZStack (alignment: .leading){
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black)
                                .frame(width: 300)
                            
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green)
                                    .frame(width: CGFloat(33)*2)
                            

                        }
                        
                        Spacer()
                                
                    }
                        
                    Spacer()
                        
                    
                    }.background(Color.red)
                
                
                
                
                
            }.background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            
            
            
        }
        .navigationTitle("pokemon")
        
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
