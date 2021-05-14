import SwiftUI

struct TagsView: View {
  @StateObject var viewModel: ViewModel
  
  init(dataController: DataController) {
    _viewModel =
      StateObject(wrappedValue: ViewModel(dataController: dataController))
  }
  
  var body: some View {
    NavigationView {
      List {
        ForEach(viewModel.tags) { tag in
          TagRowView(tag: tag)
        }
        .onMove(perform: withAnimation{viewModel.move})
        .onDelete(perform: withAnimation{viewModel.delete})
        
        undefinedTag
      }
      .navigationTitle("Tag list")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: withAnimation{viewModel.add}, label: {
            Label("Add", systemImage: "plus")
          })
          .disabled(viewModel.isAddButtonDisabled)
        }
        
        #if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
          EditButton()
            .disabled(viewModel.isEditButtonDisabled)
        }
        #endif
      }
      
      // Additional information shown for non-iOS.
      Text("Select a tag")
        .font(.largeTitle)
    }
  }
  
  // Mimic an undefined tag.
  var undefinedTag: some View {
    NavigationLink(destination: EmptyView()) {
      GeometryReader { gr in
        HStack {
          Color.gray
            .frame(width: gr.size.height)
            .clipShape(Circle())
          Text("Undefined")
        }
      }
    }
    .disabled(true)
  }
  
  static let tag: String? = "TagsView"
}

/// A helper class to represent the rows and update the view when a tag changes.
struct TagRowView: View {
  @ObservedObject var tag: Tag /// Updates the view because it observes changes.
  
  var body: some View {
    GeometryReader { gr in
      NavigationLink(destination: TagEditView(tag: tag)) {
        Color(tag.color)
          .frame(width: gr.size.height)
          .clipShape(Circle())
        Text(tag.name)
      }
    }
  }
}

struct TagsView_Previews: PreviewProvider {
  static var previews: some View {
    TagsView(dataController: DataController.preview)
  }
}
