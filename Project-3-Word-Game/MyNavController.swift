//
//  MyNavController.swift
//  Project-3-Word-Game
//
//  Created by Chasen Chamberlain on 3/5/18.
//  Copyright © 2018 Chasen Chamberlain. All rights reserved.
//

import UIKit

class MyNavController: UINavigationController{
    private var wordArray: [String] = []
    
    override func viewDidLoad() {
        self.title = "Word Games"
        super.viewDidLoad()
        //self.tabBarItem = UITabBarItem()
        
        let main = MyTableViewController()
        self.viewControllers = [main]
        
        let add: UIBarButtonItem = UIBarButtonItem.init(
            title: "New Game",
            style: UIBarButtonItemStyle.plain,
            target: self ,
            action: #selector(addGame(sender:))
        )
        
        main.navigationItem.setRightBarButton(add, animated: true)
        
        if let filepath = Bundle.main.path(forResource: "Dictionary", ofType: "txt") {
            
            do {
                let contents = try String(contentsOfFile: filepath)
                wordArray = contents.components(separatedBy: .newlines)
            } catch {
                print("Error creating dictionary")
            }
        }
        else {
            print("Couldn't find file")
        }
        
        // Add all the words into the dictionary in my data model so i can check against it.
        for word in wordArray
        {
            GameRecord.dictOfWords[word] = word
        }
    }
    
    // Method to add a new cell of a new game
    @objc func addGame(sender: UIBarButtonItem)
    {
        var gameWords: [String] = []
        var copyDict: [String] = wordArray
        var size: Int = 0
        
        while (size < 98)
        {

            let randomNum: UInt32 = arc4random_uniform(UInt32(copyDict.count))
            let someInt: Int = Int(randomNum)
            
            let word: String = copyDict[someInt]
            if((size + word.count) < 99)
            {
                gameWords.append(word)
                size += word.count
                copyDict.remove(at: someInt)
            }
            if(gameWords.contains(""))
            {
                let dumbLine = gameWords.index(of: "")
                gameWords.remove(at: dumbLine!)
            }
            if(size == 97)
            {
                gameWords.append("e")
                size += 1
            }
        }
        let toReturn: [[String]] = semiRandomPlacement(gameWords: gameWords)
        let highlighted: [IndexPath] = pickRandomHighlightedLetters(gameLetters: toReturn)
        GameRecord.appendGame(GameRecord.GameEntry(letters: toReturn, status: false, progress: 0, score: 0, highLetters: highlighted))
    }
    
    // helper method to pick 4 random highlighted letters
    func pickRandomHighlightedLetters(gameLetters: [[String]]) -> [IndexPath]
    {
        var toReturn: [IndexPath] = []
        var howMany = 0
        while(true)
        {
            let randomNumX: UInt32 = arc4random_uniform(UInt32(8))
            let someIntX: Int = Int(randomNumX)
            let randomNumY: UInt32 = arc4random_uniform(UInt32(11))
            let someIntY: Int = Int(randomNumY)
            
            let someIndex: IndexPath = IndexPath(row: someIntX, section: someIntY)
            
            if (!toReturn.contains(someIndex) && gameLetters[someIntY][someIntX] != " ")
            {
                toReturn.append(someIndex)
                howMany += 1
            }
            
            if(howMany == 4) {break}
        }
        return toReturn
    }
    
    // Long terrible method to randomly pick directions, exhausts all direction options until one is found
    func putLettersSemiRandom(_ currDir: Int, _ y: inout Int, _ toReturn: inout [Array<String>], _ x: inout Int, _ tryAgain: inout Bool, _ currLetter: String, _ options: inout [Int], _ indices: inout [Array<Int>]) {
        // up
        if(currDir == -9)
        {
            let tempY = y - 1
            if(tempY >= 0  && toReturn[tempY][x] == "666")
            {
                tryAgain = false
                toReturn[tempY][x] = currLetter
                y = tempY
                // append in the y, x
                indices.append([tempY,x])
            }
            else
            {
                let index = options.index(of: -9)
                options.remove(at: index!)
            }
        }
            // down
        else if (currDir == 9)
        {
            let tempY = y + 1
            if(tempY <= 11  && toReturn[tempY][x] == "666")
            {
                tryAgain = false
                toReturn[tempY][x] = currLetter
                y = tempY
                indices.append([tempY,x])
            }
            else
            {
                let index = options.index(of: 9)
                options.remove(at: index!)
            }
        }
            // left
        else if(currDir == -1)
        {
            let tempX = x - 1
            if(tempX >= 0  && toReturn[y][tempX] == "666")
            {
                tryAgain = false
                toReturn[y][tempX] = currLetter
                x = tempX
                indices.append([y,tempX])
            }
            else
            {
                let index = options.index(of: -1)
                options.remove(at: index!)
            }
        }
            // right
        else if(currDir == 1)
        {
            let tempX = x + 1
            if(tempX <= 8  && toReturn[y][tempX] == "666")
            {
                tryAgain = false
                toReturn[y][tempX] = currLetter
                x = tempX
                indices.append([y,tempX])
            }
            else
            {
                let index = options.index(of: 1)
                options.remove(at: index!)
            }
        }
        else if(currDir == -8)
        {
            let tempX = x - 1
            let tempY = y - 1
            if(tempX >= 0 && tempY >= 0 && toReturn[tempY][tempX] == "666" )
            {
                tryAgain = false
                toReturn[tempY][tempX] = currLetter
                x = tempX
                y = tempY
                indices.append([tempY,tempX])
            }
            else
            {
                let index = options.index(of: -8)
                options.remove(at: index!)
            }
        }
            // diagonal left/down
        else if(currDir == 8)
        {
            let tempX = x - 1
            let tempY = y + 1
            if(tempX >= 0 && tempY <= 11 && toReturn[tempY][tempX] == "666" )
            {
                tryAgain = false
                toReturn[tempY][tempX] = currLetter
                x = tempX
                y = tempY
                indices.append([tempY,tempX])
            }
            else
            {
                let index = options.index(of: 8)
                options.remove(at: index!)
            }
        }
            // diagonal right/up
        else if (currDir == -10)
        {
            let tempX = x + 1
            let tempY = y - 1
            if(tempX <= 8 && tempY >= 0 && toReturn[tempY][tempX] == "666" )
            {
                tryAgain = false
                toReturn[tempY][tempX] = currLetter
                x = tempX
                y = tempY
                indices.append([tempY,tempX])
            }
            else
            {
                let index = options.index(of: -10)
                options.remove(at: index!)
            }
        }
            // diagonal right/down
        else if (currDir == 10)
        {
            let tempX = x + 1
            let tempY = y + 1
            if(tempX <= 8 && tempY <= 11 && toReturn[tempY][tempX] == "666" )
            {
                tryAgain = false
                toReturn[tempY][tempX] = currLetter
                x = tempX
                y = tempY
                indices.append([tempY,tempX])
            }
            else
            {
                let index = options.index(of: 10)
                options.remove(at: index!)
            }
        }
    }
    
    // Helper method with semi-random placement
    func semiRandomPlacement(gameWords: [String] ) -> [[String]]
    {
        var toReturn = Array(repeating: Array(repeating: "666", count: 9), count: 12)
        let directions: [Int] = [-9, -10, 1, 10, 9, 8, -1, -8]
        var didntFit: [String] = []
        var x: Int = 0
        var y: Int = 0
        
        var howMany = 0
        while(true)
        {
            let randomNumX: UInt32 = arc4random_uniform(UInt32(8))
            let someIntX: Int = Int(randomNumX)
            let randomNumY: UInt32 = arc4random_uniform(UInt32(11))
            let someIntY: Int = Int(randomNumY)
            
            if(toReturn[someIntY][someIntX] == "666")
            {
                toReturn[someIntY][someIntX] = " "
                howMany += 1
            }
            if(howMany == 10){ break }
        }

        for word in gameWords
        {
            // keep track of where letters fall, if full word not placed, go back and pull them out and add that word to a list of words not placed.
            var indices: [[Int]] = []
            // from the x and y find the next start point by a set incrementing through the set finding the soonest 666
            var foundIt = false
            if(x != 0 && y != 0)
            {
                for findy in 0...11
                {
                    for findx in 0...8
                    {
                        if(toReturn[findy][findx] == "666")
                        {
                            y = findy
                            x = findx
                            foundIt = true
                            break
                        }
                        if(foundIt) {break}
                    }
                    if(foundIt) {break}
                }
            }
            
            for letter in word
            {
                var options = directions
                
                if (options.count > 0)
                {
                    var tryAgain: Bool = true
                    while(tryAgain && options.count != 0){
                        let randomNum: UInt32 = arc4random_uniform(UInt32(options.count))
                        let someInt: Int = Int(randomNum)
                        let currDir = options[someInt]
                        let currLetter = String(letter)
                        putLettersSemiRandom(currDir, &y, &toReturn, &x, &tryAgain, currLetter, &options, &indices)
                    } // end of while loop
                }
            } // end of for each letter
            if(indices.count != word.count)
            {
                for pair in indices
                {
                    toReturn[pair[0]][pair[1]] = "666"
                }
                // add word to an array for later filling up of the game board
                didntFit.append(word)
            }
        } // end in for word in gamewords
        
        // add the words letters that didnt fit
        var stupidLetterArray: [String] = []
        for word in didntFit
        {
            for letter in word
            {
                stupidLetterArray.append(String(letter))
            }
        }
        var arrayIndexer = 0
        for findy in 0...11
        {
            for findx in 0...8
            {
                if(toReturn[findy][findx] == "666")
                {
                    toReturn[findy][findx] = stupidLetterArray[arrayIndexer]
                    arrayIndexer = arrayIndexer + 1
                }
            }
        }
        //print (toReturn)
        return toReturn
    }
    
}
