//
//  TypeSubview.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/25.
//

import SwiftUI

struct TypeSubview: View {
    
    @Binding var selectedTab : String
    @Binding var typeString: String
    @Binding var isEditing : Bool
    var body: some View {
        
        if selectedTab == "Type" {
            
            HStack(spacing:15) {
                
                ForEach(typeArray,id: \.self){ type in
                    
                    Image(type)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            typeString = type.lowercased()
                            isEditing = false
                        }
                }
            }
            .padding(.vertical,10)
            .padding([.leading, .trailing], 20)
            .background(Color.pokeRed)
            .clipShape(Capsule())
            .shadow(color: Color.darkShadow, radius: 5, x: 2, y: 2)
            .shadow(color: Color.lightShadow, radius: 5, x: -3, y: -3)
            

        }
        if selectedTab == "Gen" {
            HStack(spacing:15) {
                
                ForEach(generation,id: \.self){ gen in
                    
                    Text("\(gen)")
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            print("\(gen)")
                            typeString = gen
                            
                            isEditing = false
                        }
                }
                
            }
            .padding(.vertical,10)
            .padding([.leading, .trailing], 20)
            .background(Color.pokeRed)
            .clipShape(Capsule())
            .shadow(color: Color.darkShadow, radius: 5, x: 2, y: 2)
            .shadow(color: Color.lightShadow, radius: 5, x: -3, y: -3)
        }
    }
}

extension View {
  @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
      case true: self.hidden()
      case false: self
    }
  }
}
