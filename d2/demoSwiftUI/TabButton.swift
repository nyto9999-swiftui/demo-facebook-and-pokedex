//
//  TabButton.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/25.
//

import SwiftUI

struct TabButton: View {
    var title : String
    var animation : Namespace.ID
    @Binding var selectedTab : String
    
    var body: some View {
        Button(action:{
            
            withAnimation(.spring()){selectedTab = title}
            
        }, label: {
            VStack(alignment: .leading, spacing: 6, content: {
                Text(title)
                    .fontWeight(.heavy)
                    .foregroundColor(selectedTab == title ? .red : .black.opacity(0.4))
                    .minimumScaleFactor(0.1)
                    .font(.title3)
                    .lineLimit(1)
                 
                   
                
                if selectedTab == title {
                    Capsule()
                        .fill(Color.red)
                        .frame(width: 40, height: 4)
                        .matchedGeometryEffect(id: "Tab", in: animation)
                }
            })
        })
        
        // default width
        .frame(width: 100)
        
    }
}

