//
//  ContentView.swift
//  RememberMe
//
//  Created by Christopher Fouts on 11/18/21.
//

import SwiftUI

class People : ObservableObject {
    @Published var images = [UUID : UIImage]()
    @Published var people = [Person]()


    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        let filename = paths[0].appendingPathComponent("SavedPeople")

        do {
            let data = try Data(contentsOf: filename)
            people = try JSONDecoder().decode([Person].self, from: data)

            for person in people
            {
                let url = paths[0].appendingPathComponent(person.id.uuidString)

                let jpeg = UIImage.init(contentsOfFile: url.path)

                self.images[person.id] = jpeg
            }

        } catch {
            print("Unable to initialize saved data.")
            self.people = []
        }
    }
}

class DisplaySettings: ObservableObject {
    @Published var showingPersonView = false
}

struct ContentView: View {
    
    @State private var showingImagePicker = false
    @StateObject var settings = DisplaySettings()
    @State private var firstPerson = true
    @State private var inputImage : UIImage?
    
    @ObservedObject var p = People()
    
    
    var body: some View {
        let defaultImage =  UIImage(systemName:"person")!
  
        NavigationView {
            if settings.showingPersonView {
                if p.people.count > 0 {
                    let currentPerson = p.people[p.people.count - 1]
                    NavigationLink(destination: PersonView(settings: settings, person:p.people[p.people.count - 1], personImage: p.images[currentPerson.id] ?? defaultImage), isActive: $settings.showingPersonView) { EmptyView() }
                    .onDisappear(perform: savePeople)
                }
            } else {
                List {
                    ForEach(p.people, id: \.self) { person in
                        let personImage =  p.images[person.id] ?? defaultImage
                        NavigationLink(destination: PersonView(settings: settings, person: person, personImage: personImage)) {
                            HStack {
                                Image(uiImage: personImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 75)
                                Text(person.name)
                            }
                        }
                        .onDisappear(perform: savePeople)

                    }
                    .onDelete(perform: delete)
                }
                .navigationTitle("RememberMe")
                .navigationBarItems(leading: EditButton(), trailing:
                    Button(action: {
                        self.showingImagePicker = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                )
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                        .onDisappear(perform: showPerson)
                }
                .onAppear(perform: loadPeople)
            }
        }
    
    }
    
    func delete(at offsets: IndexSet) {
        for offset in offsets {
            let person = p.people[offset]
            p.images.removeValue(forKey: person.id)
            p.people.remove(at: offset)
        }
        
        savePeople()
    }
    
    func showPerson() {
        settings.showingPersonView = true
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {
            return
        }
        let person = Person(name: "")
        p.people.append(person)
        p.images[person.id] = inputImage
        settings.showingPersonView = true
    }
    
    func loadPeople() {
        if p.people.isEmpty {
            let baseURL = getDocumentsDirectory()
            let filename = baseURL.appendingPathComponent("SavedPeople")

            do {
                let data = try Data(contentsOf: filename)
                p.people = try JSONDecoder().decode([Person].self, from: data)
                
                for person in p.people
                {
                    let url = baseURL.appendingPathComponent(person.id.uuidString)
                    
                    let jpeg = UIImage.init(contentsOfFile: url.path)

                    p.images[person.id] = jpeg
                }
            } catch {
                print("Unable to load saved data.")
            }
        } else {
            savePeople()
        }

    }
    
    func savePeople() {

        let baseURL = getDocumentsDirectory()

        do {
            let filename = baseURL.appendingPathComponent("SavedPeople")
            let data = try JSONEncoder().encode(p.people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }

        for person in p.people {

            let url = baseURL.appendingPathComponent(person.id.uuidString)
            guard let uiImage = p.images[person.id] else { return }

            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: url, options: [.atomicWrite, .completeFileProtection])
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
    }
}
