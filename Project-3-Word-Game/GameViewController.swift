//
//  GameViewController.swift
//  Project-3-Word-Game
//
//  Created by Chasen Chamberlain on 3/6/18.
//  Copyright © 2018 Chasen Chamberlain. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UIGestureRecognizerDelegate
{
    
    private let cellReuseIdentifier = "collectionCell"
    
    // The index of the whole game, to get the gameboard correctly
    private let index: Int
    // The arrayIndex so we populate letters correctly
    private var arrayIndex: Int = 0
    // The string that is being built from selections
    private var word: String
    {
        get
        {
            if let testWord = currentWord.text
            {
                return testWord
            }
            return ""
        }
        set
        {
            currentWord.text = newValue
        }
    }
    
    // This var is so the selection paths are in order of selection.
    private var indexOfSelections: [IndexPath] = []
    
    // Progress as in letters on the board, starts at 0
    private var progressInt: Double = 0.0
    private var totalProgressInt: Double
    {
        return Double(GameRecord.gameEntries[index].progress)
    }
    
    // x and y are for adding letters from the gamedata
    private var x: Int = 0
    private var y: Int = 0
    
    // a variable that gets checked to see if we need to erase a previous selection
    private var backwardsBool: Bool = false
    
    // Labels for the collection view
    private var currentWord: UILabel = UILabel()
    private var points: UILabel = UILabel()
    private var progress: UILabel = UILabel()
    
    // The status of the game board
    private var status: Bool
    {
        return GameRecord.gameEntries[index].status
    }
    
    // Score of the game
    private var score: Int
    {
        return GameRecord.gameEntries[index].score
    }
    
    // The pre chosen highlighted letters that clear entire rows
    private var highlighted: [IndexPath]
    {
        return GameRecord.gameEntries[index].highlightedLetters
    }
    
    // indexes of cells in the order they were picked
    private var lastSelectedCell = IndexPath()
    private var currentSelectedCell = IndexPath()
    
    // The gameboard data
    private var gameData: [[String]]
    {
        return GameRecord.gameEntries[index].letters
    }
    
    // This will be for copying the current game data to alter it then making it the new game data
    private var otherGameData: [[String]] = []
    private var otherHighlights: [IndexPath] = []
    
    // The collection view of cells
    var collectionView: UICollectionView
    
    init(theIndex: Int){
        
        index = theIndex
        let collectFrame: CGRect = CGRect(x: 0, y: UIScreen.main.bounds.midY/2, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height )
        collectionView = UICollectionView(frame: collectFrame, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(nibName: nil, bundle: nil)
        let end: UIBarButtonItem = UIBarButtonItem.init(
            title: "End Game",
            style: UIBarButtonItemStyle.plain,
            target: self ,
            action: #selector(endGame(sender:))
        )
        currentWord.frame = CGRect(x: 0, y: UIScreen.main.bounds.width/5 , width: UIScreen.main.bounds.width, height: 40)
        points.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 40)
        progress.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - 40, width: UIScreen.main.bounds.width, height: 40)
        currentWord.textAlignment = .center
        points.textAlignment = .center
        progress.textAlignment = .center
        points.text = "\(score)"
        points.font = points.font.withSize(40)
        currentWord.font = currentWord.font.withSize(30)
        self.navigationItem.setRightBarButton(end, animated: true)
        setupCollectionView()
        progress.text = "\(Int(totalProgressInt))% Finished"
        title = "SpellTower"
    }
    
    // Appple stuff
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to stop the game at the current state.
    @objc func endGame(sender: UIBarButtonItem){
        GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(
            letters: gameData,
            status: true,
            progress: Int(totalProgressInt),
            score: score,
            highLetters: otherHighlights))
        self.collectionView.allowsSelection = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dumbView: UIView = UIView(frame: UIScreen.main.bounds)
        dumbView.backgroundColor = UIColor.white
        self.view.addSubview(dumbView)
        self.view.addSubview(collectionView)
        self.view.addSubview(currentWord)
        self.view.addSubview(points)
        self.view.addSubview(progress)
        collectionView.reloadData()
    }
    
    // Helper method to set up my collection view
    func setupCollectionView() {
        collectionView.allowsMultipleSelection = true
        collectionView.canCancelContentTouches = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(toSelectCells:)))
        panGesture.delegate = self
        collectionView.addGestureRecognizer(panGesture)
        collectionView.register(GameViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
    }
    
    // Helper method to display a messag if clearing the whole board
    private func showWinMessage()
    {
        //Setting title and message for the alert dialog
        let alert = UIAlertController(title: "Board cleared!", message: "You cleared the board with a score of \(score).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    
    // Moves the highlighted letters down if needed
    fileprivate func moveDownHighlightedLetters(_ index: IndexPath) {
        if(index.section > 0)
        {
            for j in (0 ... index.section - 1).reversed()
            {
                let tempIndexPath: IndexPath = IndexPath(row: index.row, section: j)
                if(otherHighlights.contains(tempIndexPath))
                {
                    let indexToChange = otherHighlights.index(of: tempIndexPath)
                    otherHighlights[indexToChange!] = IndexPath(row: index.row, section: otherHighlights[indexToChange!].section + 1)
                }
            }
        }
    }

    // Helps shift my board down to show that tiles are disappearing
    fileprivate func shiftTiles(_ index: IndexPath) {
        moveDownHighlightedLetters(index)
        
        for i in (0 ... index.section).reversed()
        {
            
            if(i != 0)
            {
                otherGameData[i][index.row] = otherGameData[i-1][index.row]
            }
            else if(i == 0)
            {
                otherGameData[0][index.row] = " "
            }
        }
    }
    
    // helper method that assists in shifting game tiles
    fileprivate func shiftGameTiles() {
        if collectionView.indexPathsForSelectedItems != nil
        {
            // check for empty spaces arround correct word here
            checkForEmptyNeighbors()
            for index in self.indexOfSelections
            {
                if(otherHighlights.contains(index))
                {
                    var tempIndexPath: IndexPath = IndexPath()
                    var count = 0
                    while(true)
                    {
                        tempIndexPath = IndexPath(row: count, section: index.section)
                        if let indexToRemove = otherHighlights.index(of: tempIndexPath)
                        {
                            otherHighlights.remove(at: indexToRemove)
                        }
                        shiftTiles(tempIndexPath)
                        count += 1
                        if(gameData[tempIndexPath.section][tempIndexPath.row] != " ")
                        {
                            progressInt += 1.0
                        }
                        

                        
                        if(count == 9) {break}
                    }
                }
                else
                {
                    shiftTiles(index)
                }
            }
        }
    }
    
    // dumb big helper method that checks for empty neighbors
    func checkForEmptyNeighbors(){
        for index in self.indexOfSelections
        {
            let y = index.section
            let x = index.row
            // up
            var tempY = y - 1
            if(tempY >= 0  && gameData[tempY][x] == " ")
            {
                let emptyIndex: IndexPath = IndexPath(row: x, section: tempY)
                shiftTiles(emptyIndex)
            }
            // down
            tempY = y + 1
            if(tempY <= 11 && gameData[tempY][x] == " ")
            {
                let emptyIndex: IndexPath = IndexPath(row: x, section: tempY)
                shiftTiles(emptyIndex)
            }
            // left
            var tempX = x - 1
            if(tempX >= 0  && gameData[y][tempX] == " ")
            {
                let emptyIndex: IndexPath = IndexPath(row: tempX, section: y)
                shiftTiles(emptyIndex)
            }
            // right
            tempX = x + 1
            if(tempX <= 8  && gameData[y][tempX] == " ")
            {
                let emptyIndex: IndexPath = IndexPath(row: tempX, section: y)
                shiftTiles(emptyIndex)
            }
        }
    }
    
    // Helper method to assist in selecting cells and deselecting cells
    func selectCell(_ indexPath: IndexPath, selected: Bool) {
        if let cell = collectionView.cellForItem(at: indexPath)
        {
            // deselects a cell
            if(cell.isSelected && collectionView.indexPathsForSelectedItems!.count > 1)
            {
                collectionView.deselectItem(at: indexOfSelections.last!, animated: true)
                indexOfSelections.removeLast()
                word.removeLast()
                print(word)

            }
            else
            {
                // selecting a new cell
                if(!indexOfSelections.contains(indexPath))
                {
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                    self.indexOfSelections.append(indexPath)
                    let cell: GameViewCell = collectionView.cellForItem(at: indexPath) as! GameViewCell
                    word.append(cell.nameLbl.text!)
                }
            }
            eraseOldLines()
            print(indexOfSelections)
            drawLinesOnGameBoard()
            if (collectionView.indexPathsForSelectedItems?.count) != nil
            {
                currentWord.text = word
            }
        }
    }
    
    // Gets called by pan gestures on finger drags
    fileprivate func drawLinesOnGameBoard() {
        if(GameRecord.dictOfWords.values.contains(word))
        {
            collectionView.drawLineFrom(paths: self.indexOfSelections, lineWidth: 2, strokeColor: UIColor.green)
        }
        else
        {
            collectionView.drawLineFrom(paths: self.indexOfSelections, lineWidth: 2, strokeColor: UIColor.red)
        }
    }
    
    // Large method for pan gestures
    @objc func didPan(toSelectCells panGesture: UIPanGestureRecognizer) {
        if(status == false)
        {
            // Start of the finger being placed
            if (panGesture.state == .possible || panGesture.state == .began)
            {
                let location: CGPoint = panGesture.location(in: collectionView)
                if let indexPath: IndexPath = collectionView.indexPathForItem(at: location)
                {
                    indexOfSelections.append(indexPath)
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                    lastSelectedCell = indexPath
                    let cell: GameViewCell = collectionView.cellForItem(at: indexPath) as! GameViewCell
                    word.append(cell.nameLbl.text!)
                }
                collectionView.isUserInteractionEnabled = false
                collectionView.isScrollEnabled = false
            }
            // Once the finger has started to drag
            else if panGesture.state == .changed
            {
                let location: CGPoint = panGesture.location(in: collectionView)
                if let indexPath: IndexPath = collectionView.indexPathForItem(at: location)
                {
                    if indexPath != lastSelectedCell
                    {
                        lastSelectedCell = indexPath
                        self.selectCell(indexPath, selected: true)
                    }

                }
            }
            
            // The pan gesture has ended, time to process if words were made correctly
            else if panGesture.state == .ended
            {
                otherGameData = gameData
                otherHighlights = highlighted
                
                // The word is in the dictionary
                if(GameRecord.dictOfWords.values.contains(word)){
                    collectionView.drawLineFrom(paths: self.indexOfSelections, lineWidth: 2, strokeColor: UIColor.green)
                    progressInt = progressInt + Double(word.count)
                    
                    // bunch of score stuff
                    var tempScore = score
                    if(word.count <= 2)
                    {
                        tempScore += Int(progressInt)
                        GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(letters: otherGameData, status: false, progress: Int(progressInt/98 * 100), score: tempScore, highLetters: otherHighlights))

                    }
                    else if (word.count > 2 && word.count <= 4 )
                    {
                        tempScore += Int(progressInt + 2)
                        GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(letters: otherGameData, status: false, progress: Int(progressInt/98 * 100), score: tempScore, highLetters: otherHighlights))
                    }
                    else
                    {
                        tempScore += Int(progressInt + 4)
                        GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(letters: otherGameData, status: false, progress: Int(progressInt/98 * 100), score: tempScore, highLetters: otherHighlights))
                    }
                    points.text = String(score)
                    
                    // Cleared all letter tiles.
                    if progressInt == 98.0
                    {
                        GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(letters: otherGameData, status: true, progress: Int(progressInt/98 * 100), score: score, highLetters: otherHighlights))
                        collectionView.allowsSelection = false
                        self.title = "CLEARED!!"
                        showWinMessage()
                    }

                    
                    shiftGameTiles()
                    // update the game records
                    GameRecord.editGameEntry(atIndex: index, newGameEntry: GameRecord.GameEntry(letters: otherGameData, status: status, progress: Int(progressInt/98 * 100), score: score, highLetters: otherHighlights))
                    
                    // Set the progress.text to the correct number
                    progress.text = "\(Int(totalProgressInt))% Finished"
                }
                else
                {
                }
                word = ""
                indexOfSelections = []
                
                // After a touch has ended this deselects the cells
                if let numberOfSelections = collectionView.indexPathsForSelectedItems
                {
                    for index in numberOfSelections
                    {
                        collectionView.deselectItem(at: index, animated: true)
                    }
                }
                
                eraseOldLines()
                collectionView.reloadData()
                collectionView.isScrollEnabled = true
                collectionView.isUserInteractionEnabled = true
            }
        }
        
    }
    
    // Erases old lines so we are always drawing the correct lines
    fileprivate func eraseOldLines() {
        // To delete the line that was drawn.
        if let thing = collectionView.layer.sublayers?.count
        {
            var layers = collectionView.layer.sublayers
            for index in 0...(thing-1)
            {
                let lay: CALayer = layers![index]
                if(lay is CAShapeLayer)
                {
                    lay.removeFromSuperlayer()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 9
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GameViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! GameViewCell
        
        let backgroundView: UIView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor.red
        cell.selectedBackgroundView = backgroundView
        cell.nameLbl.text = gameData[indexPath.section][indexPath.row]
        if(highlighted.contains(indexPath))
        {
            cell.contentView.backgroundColor = .green
        }
        else
        {
            cell.contentView.backgroundColor = UIColor.darkGray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: collectionView.bounds.width/12, height: collectionView.bounds.width/12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0, left: collectionView.bounds.width/10, bottom: 1, right: collectionView.bounds.width/10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
}

// Extension to allow drawing between cells
extension UICollectionView {
    
    func drawLineFrom( paths: [IndexPath], lineWidth: CGFloat = 2, strokeColor: UIColor = UIColor.blue) {
        var start = 0; var next = 1

        if(paths.count >= 2)
        {
            while(next < paths.count)
            {
                let from = paths[start]
                let to = paths[next]
                guard
                    let fromPoint = cellForItem(at: from as IndexPath)?.center,
                    let toPoint = cellForItem(at: to as IndexPath)?.center
                    else {
                        return
                }
                let layer = CAShapeLayer()
                let path = UIBezierPath()

                path.move(to: convert(fromPoint, to: self))
                path.addLine(to: convert(toPoint, to: self))
                
                
                layer.path = path.cgPath
                layer.lineWidth = lineWidth
                layer.strokeColor = strokeColor.cgColor
                
                self.layer.addSublayer(layer)
                start += 1; next += 1
            }
        }
    }
}

// Custom class for the cells
class GameViewCell: UICollectionViewCell
{
    public let nameLbl: UILabel = UILabel()
    var letter: String?
    {
        get
        {
            return nameLbl.text
        }
        set
        {
            nameLbl.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nameLbl.frame = contentView.frame
        self.contentView.backgroundColor = .gray
        nameLbl.textAlignment = NSTextAlignment.center
        nameLbl.font = nameLbl.font.withSize(25)
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        self.nameLbl.textColor = .white
        self.contentView.addSubview(nameLbl)
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 2.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        self.contentView.frame = bounds
    }
}
