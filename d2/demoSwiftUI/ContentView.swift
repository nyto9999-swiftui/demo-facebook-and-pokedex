//
//  ContentView.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/22.
//

import SwiftUI
import Kingfisher



struct ContentView: View {
@State var isEditing = false
@State var searchText = ""
@StateObject var pokeVM = PokemonVM()
@State var selectedTab = scroll_Tabs[0]
@State var type: String = ""
@Namespace var animation

private var isInt: Bool {
if type.isInt {
    return true
}
else {
    return false
}
}


var body: some View {

ZStack {
    Color(red: 219/255, green: 215/255, blue: 207/255).edgesIgnoringSafeArea(.all)
    
    ScrollView {
        VStack {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom), content: {
                HStack {
                    Text("Pokemon")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.red).opacity(0.8)
                    Spacer()
                    
                }
                .padding()
                ScrollView(.horizontal, showsIndicators: false){
                    
                    TypeSubview(selectedTab: $selectedTab, typeString: $type, isEditing: $isEditing)
                        .padding()
                 
                }
            })
            .edgesIgnoringSafeArea([.leading, .trailing])
            
            
            ScrollView (.horizontal, showsIndicators: false) {
                
                HStack (spacing: 15){
                    ForEach(scroll_Tabs.dropFirst(), id:\.self){tab in
                        
                        TabButton(title: tab, animation: animation, selectedTab: $selectedTab)
                        
                        
                    }
                    Spacer()
                }
            }
            .padding()
            
        }
				
        //Search bar
        HStack {
            NeumorphicStyleTextField(textField: TextField("Search...", text: $searchText), imageName: "magnifyingglass")
                .onTapGesture {
                    self.isEditing = true
                }
        }
        .padding()
 
        // 按下搜尋匡 isEditing = true   v
        if isEditing {
            if !searchText.isEmpty {
                searchedPokemon(pokemon: pokeVM.pokemons, searchText: searchText)
            }
        }
        else {
            Section(header: Text(type.isInt ? "Generation \(type.capitalized)" : "\(type.capitalized)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(0.8)
                        .foregroundColor(.red)){
                ScrollView {
                    searchByGen(genDict: pokeVM.genDict, type: type)
                    
                    searchByType(typeDict: pokeVM.pokemonDict, type: type)
                }
            }
        }
        
        
        
        
        
    }
}.listStyle(GroupedListStyle())
}







struct ContentView_Previews: PreviewProvider {
static var previews: some View {
ContentView()
}
}

struct searchByGen: View {
let genDict: [String:[PokemonByGen]]
let type: String

var body: some View {

LazyVGrid(columns: [
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16)
], content:     {
    
    //searched pokemon list
    if let gen = genDict["\(type)"] {
        ForEach(0..<gen.count, id: \.self) { index in
            HStack (content: {
                
                VStack{
                    Text(gen[index].name.capitalized)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .font(.title)
                        .padding(.top, 5)
                    
                    KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(gen[index].url[42..<gen[index].url.count-1]).png"))
                        .resizable()
                        .frame(width: 125, height: 125)
                    
                }
                .background(Color.pokeRed)
                .foregroundColor(Color(red: 219/255, green: 215/255, blue: 207/255))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 1.35)
                    
                )
            })
        }
    }
}).padding([.leading, .trailing], 14)
}
}

struct searchByType: View {
let typeDict : [String:[Pokemons]]
let type : String

var body: some View {
LazyVGrid(columns: [
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16)
], content:     {
    
    //searched pokemon list
    if let kind = typeDict["\(type)"] {
        ForEach(0..<kind.count, id: \.self) { index in
            HStack (content: {
                
                VStack{
                    Text(kind[index].pokemon.name.capitalized)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .font(.title)
                        .padding(.top, 5)
                    
                    KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(kind[index].pokemon.url[34..<kind[index].pokemon.url.count-1]).png"))
                        .resizable()
                        .frame(width: 125, height: 125)
                    
                }
                .background(Color.pokeRed)
                .foregroundColor(Color(red: 219/255, green: 215/255, blue: 207/255))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 1.35)
                    
                )
            })
        }
    }
    
}).padding([.leading, .trailing], 14)
}
}

struct searchedPokemon: View {
let pokemon: [PokemonInfo]
let searchText : String
var body: some View {

LazyVGrid(columns: [
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16)
], content:     {
    
    //searched pokemon list
    
    ForEach((pokemon).filter({ $0.name.capitalized.contains(searchText) }), id: \.self) { pokemon in
    VStack {
        
        Text("\(pokemon.name.capitalized)")
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .font(.title)
            .padding(.top, 5)
        KFImage(URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.url[34..<pokemon.url.count-1]).png"))
            .resizable()
            .frame(width: 125, height: 125)
        
    }
    .background(Color.pokeRed)
    .foregroundColor(Color(red: 219/255, green: 215/255, blue: 207/255))
    .cornerRadius(6)
    .overlay(
        RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 1.35)
        
    )
}
    
}).padding([.leading, .trailing], 14)

}
}




struct NeumorphicStyleTextField: View {
var textField: TextField<Text>
var imageName: String
var body: some View {
HStack {
    Image(systemName: imageName)
        .foregroundColor(.darkShadow)
    textField
        .textContentType(.oneTimeCode)
    
}
.padding()
.foregroundColor(.neumorphictextColor)
.background(Color.background)
.cornerRadius(6)
.shadow(color: Color.darkShadow, radius: 3, x: 2, y: 2)
.shadow(color: Color.lightShadow, radius: 3, x: -2, y: -2)

}
}


}
