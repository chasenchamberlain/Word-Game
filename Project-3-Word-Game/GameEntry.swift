//
//  DataModel.swift
//  Project-3-Word-Game
//
//  Created by Chasen Chamberlain on 3/5/18.
//  Copyright © 2018 Chasen Chamberlain. All rights reserved.
//

import Foundation

protocol DataModelDelegate: class {
    var delegateID: String { get }
    func dataModelUpdated()
}

final class GameRecord
{
    // Represents one game board and its infromation
    final class GameEntry
    {
        let letters: [[String]]
        let status: Bool
        let progress: Int
        let score: Int
        let highlightedLetters: [IndexPath]
        
        init(letters: [[String]], status: Bool, progress: Int, score: Int, highLetters: [IndexPath])
        {
            self.letters = letters
            self.status = status
            self.progress = progress
            self.score = score
            self.highlightedLetters = highLetters
        }
    }
    
    private static var delegates: [String: WeakDataModelDelegate] = [:]
    public static var gameEntries: [GameEntry] = []
    public static var dictOfWords = [String:String]()
    
    private final class WeakDataModelDelegate
    {
        weak var delegate: DataModelDelegate?
        init(delegate: DataModelDelegate)
        {
            self.delegate = delegate
        }
    }
    
    static var count: Int
    {
        var count: Int = 0
        count = gameEntries.count
        return count
    }
    
    // Returns a game at a certain index
    static func entry(atIndex index: Int ) -> GameEntry
    {
        var gameEntry: GameEntry?
        gameEntry = gameEntries[index]
        return gameEntry!
    }
    
    // Add a game
    static func appendGame(_ gameEntry: GameEntry)
    {
        gameEntries.append(gameEntry)
        DataModel.accessor.addGameData(gameLetters: gameEntry.letters,
                                       status: gameEntry.status,
                                       prog: gameEntry.progress,
                                       totalScore: gameEntry.score,
                                       highLetters: gameEntry.highlightedLetters)
        delegates.values.forEach({ (weakDelegate: WeakDataModelDelegate) in weakDelegate.delegate?.dataModelUpdated()})
    }
    
    // Edit a game
    static func editGameEntry(atIndex index: Int, newGameEntry entry: GameEntry)
    {
        gameEntries[index] = entry
        DataModel.accessor.letters[index] = entry.letters
        DataModel.accessor.gameStatus[index] = entry.status
        DataModel.accessor.progress[index] = entry.progress
        DataModel.accessor.score[index] = entry.score
        DataModel.accessor.highlightedLetters[index] = entry.highlightedLetters
        delegates.values.forEach({ (weakDelegate: WeakDataModelDelegate) in weakDelegate.delegate?.dataModelUpdated()})

    }
    
    // register a delegate
    static func registerDelegate(_ delegate: DataModelDelegate)
    {
        delegates[delegate.delegateID] = WeakDataModelDelegate(delegate: delegate)
    }
    
}

// Holds all of the game data for easy write and read functionality
class DataModel: Codable
{
    // Accessor for my data model.
    static var accessor = DataModel()
    var letters: [[[String]]] = []
    var gameStatus: [Bool] = []
    var progress: [Int] = []
    var score: [Int] = []
    var highlightedLetters: [[IndexPath]] = []
    
    func addGameData (gameLetters: [[String]], status: Bool, prog: Int, totalScore: Int, highLetters: [IndexPath])
    {
        letters.append(gameLetters)
        gameStatus.append(status)
        progress.append(prog)
        score.append(totalScore)
        highlightedLetters.append(highLetters)
    }
    
    func sortThings()
    {
        if(GameRecord.gameEntries.count > 1)
        {
            var startIndex = 0
            for i in (0 ... GameRecord.gameEntries.count - 1)
            {
                if(gameStatus[i] == true)
                {
                    gameStatus.swapAt(i, startIndex)
                    letters.swapAt(i, startIndex)
                    progress.swapAt(i, startIndex)
                    score.swapAt(i, startIndex)
                    highlightedLetters.swapAt(i, startIndex)
                    GameRecord.gameEntries.swapAt(i, startIndex)
                    startIndex += 1
                }
            }
        }
    }
    
    // Save the data to json
    func saveData(){
        let jsonData = try? JSONEncoder().encode(DataModel.accessor)
        
        let urlDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let directory: URL = (urlDirectory?.appendingPathComponent("WordGame.json"))!
        
        try! jsonData?.write(to: directory)
    }
    
    // Load the date from json
    func loadData(){
        GameRecord.gameEntries = []
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let url = path?.appendingPathComponent("WordGame.json")
        
        if let jsonData = FileManager.default.contents(atPath: (url?.path)!)
        {
            do
            {
               let decodedObj = try? JSONDecoder().decode(DataModel.self, from: jsonData)
                DataModel.accessor = decodedObj ?? DataModel()
            }
        }
        
        if(DataModel.accessor.letters.count > 0)
        {
            for index in 0 ... (DataModel.accessor.letters.count - 1)
            {
                GameRecord.appendGame(GameRecord.GameEntry.init(
                    letters: DataModel.accessor.letters[index],
                    status: DataModel.accessor.gameStatus[index],
                    progress: DataModel.accessor.progress[index],
                    score: DataModel.accessor.score[index],
                    highLetters: DataModel.accessor.highlightedLetters[index]))
            }
        }
    }
}

