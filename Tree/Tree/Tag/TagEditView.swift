import SwiftUI

struct TagEditView: View {
  @ObservedObject var tag: Tag
  
  @EnvironmentObject var dataController: DataController
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var color: String
  @State private var isDeletionAlertActive = false
  
  init(tag: Tag) {
    self.tag = tag
    
    _name = State(wrappedValue: tag.name)
    _color = State(wrappedValue: tag.color)
  }
  
  var body: some View {
    Form {
      Section(header: Text("Settings")) {
        TextField("Name", text: $name.onChange(update))
      }
      
      Section(header: Text("Colors")) {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
          ForEach(Tag.colors, id: \.self) { item in
            ZStack {
              Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
              
              if item == color {
                Image(systemName: "checkmark.circle")
                  .foregroundColor(.white)
                  .font(.largeTitle)
              }
            }
            .onTapGesture {
              color = item
              update()
            }
          }
        }
        .padding(.vertical)
      }
      
      Section(footer: Text("Warning: it removes the tag forever.")) {
        Button("Delete this tag") {
          isDeletionAlertActive.toggle()
        }
        .accentColor(.red)
      }
    }
    .alert(isPresented: $isDeletionAlertActive) {
      Alert(title: Text("Delete tag?"),
            message: Text("Are you sure you want to delete this tag?"),
            primaryButton: .default(Text("Delete"), action: delete),
            secondaryButton: .cancel())
    }
    .navigationTitle("Edit tag")
    .onDisappear(perform: dataController.save)
  }
  
  func update() {
    tag.objectWillChange.send()
    tag.name = name
    tag.color = color
  }
  
  func delete() {
    tag.isZombie = true
    presentationMode.wrappedValue.dismiss()
  }
}

struct TagEditView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      TagEditView(tag: Tag.example)
    }
  }
}
