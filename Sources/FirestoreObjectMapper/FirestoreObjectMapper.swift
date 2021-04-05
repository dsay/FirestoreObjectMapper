import ObjectMapper
import FirebaseFirestore

public enum FBError: Error {
    case parsingFailure
}

extension DocumentReference {
    
    func getDocument<Item: Mappable>(source: FirestoreSource = .default, completion: @escaping (Swift.Result<Item, Error>) -> Void) {
        self.getDocument(source: source) { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                let mapper = Mapper<Item>(context: nil, shouldIncludeNilValues: false)
                
                if let jsonItem = snapshot?.data(), let item = mapper.map(JSON: jsonItem) {
                    completion(.success(item))
                } else {
                    completion(.failure(FBError.parsingFailure))
                }
            }
        }
    }
    
    func addSnapshotListener<Item: Mappable>(includeMetadataChanges: Bool = true, completion: @escaping (Swift.Result<Item, Error>) -> Void) {
        self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                let mapper = Mapper<Item>(context: nil, shouldIncludeNilValues: false)
                
                if let jsonItem = snapshot?.data(), let item = mapper.map(JSON: jsonItem) {
                    completion(.success(item))
                } else {
                    completion(.failure(FBError.parsingFailure))
                }
            }
        }
    }
}

extension Query {
    
    func addSnapshotsListener<Item: Mappable>(includeMetadataChanges: Bool = true, completion: @escaping (Swift.Result<[Item], Error>) -> Void) {
        self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                let mapper = Mapper<Item>(context: nil, shouldIncludeNilValues: false)
                
                if let jsonItems = snapshot?.documents {
                    let items: [Item] = jsonItems.compactMap { mapper.map(JSON: $0.data()) }
                    completion(.success(items))
                } else {
                    completion(.failure(FBError.parsingFailure))
                }
            }
        }
    }
    
    func getDocuments<Item: Mappable>(source: FirestoreSource = .default, completion: @escaping (Swift.Result<[Item], Error>) -> Void) {
        self.getDocuments(source: source) { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                let mapper = Mapper<Item>(context: nil, shouldIncludeNilValues: false)
                
                if let jsonItems = snapshot?.documents {
                    let items: [Item] = jsonItems.compactMap { mapper.map(JSON: $0.data()) }
                    completion(.success(items))
                } else {
                    completion(.failure(FBError.parsingFailure))
                }
            }
        }
    }
}
