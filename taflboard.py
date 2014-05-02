#!/usr/bin/python2

import random
import sys

# This module defines the board class. A board object contains a 2D array of values
# defined as 2 layers of lists, as in [[1,2],[3,4]]. The board also tracks turns and
# can be initialized to any size. If a size isn't defined, the board defaults to
# 11x11 and fills itself with a properly set up hnefatafl board.

# Use the method 'board.humanTakeTurn([x,y,newx,newy])' where x and y are the coordinates
# of the piece to be moved and newx and newy are the coordinates of the square to be moved
# to.

# Use the method '.aiTakeTurnBasic()' to request a move from the basic AI.

# Both of the above methods will update the board state and turn when they are made.

# These values are used to avoid a bunch of hard to read numbers in the code.
# Note that WHITE and BLACK are used both to designate piece type and player turn.
# Please note that because of this, turn cannot be toggled with 'turn = not turn'
# Instead, please use the .getOppositeColor(color) method
EMPTY = 0
WHITE = 1
BLACK = 2
KING = 3

class board:
    # The board will instantiate to an 11 by 11 board with pieces set up in their
    # starting configuration. If you create a board object with an input other than nothing
    # or 11, it will be empty. I wouldn't recommend it though, as there are a bunch of assumptions of
    # size 11 that I probably aren't going to fix in this code. Instantiate to a nonstandard size at
    # your own risk
    def __init__(self,size = 11):
        self.squares = [[EMPTY for j in range(size)] for i in range(size)]
        self.size = size
        self.turn = WHITE
        self.win = EMPTY

        # Set up the board

        if size == 11:
            # Place the king
            self.squares[5][5] = KING

            # Set up the black pieces
            for i in range(5):
                self.squares[i+3][0] = BLACK 
                self.squares[i+3][10] = BLACK 
                self.squares[0][i+3]= BLACK 
                self.squares[10][i+3] = BLACK 

            self.squares[1][5] = BLACK 
            self.squares[5][1] = BLACK 
            self.squares[9][5] = BLACK 
            self.squares[5][9] = BLACK 

            # Set up the white pieces
            self.squares[3][5] = WHITE 

            self.squares[4][4] = WHITE 
            self.squares[4][5] = WHITE 
            self.squares[4][6] = WHITE 

            self.squares[5][3] = WHITE 
            self.squares[5][4] = WHITE 
            self.squares[5][6] = WHITE 
            self.squares[5][7] = WHITE 

            self.squares[6][4] = WHITE 
            self.squares[6][5] = WHITE 
            self.squares[6][6] = WHITE 

            self.squares[7][5] = WHITE 

    # Prints out the board for debugging
    def printBoard(self):
        for i in range(self.size):
            for j in range(self.size):
                if self.getSquare(i,j) == WHITE:
                    sys.stdout.write('W')
                elif self.getSquare(i,j) == BLACK:
                    sys.stdout.write('B')
                elif self.getSquare(i,j) == EMPTY:
                    sys.stdout.write(' ')
                elif self.getSquare(i,j) == KING:
                    sys.stdout.write('K')
            sys.stdout.write('\n')
        if self.turn == WHITE:
            print "WHITE"
        else:
            print "BLACK"

    # Returns the turn
    def getTurn(self):
        return self.turn

    # Returns the color opposite from the one passed
    def getOppositeColor(self,color):
        if color == WHITE:
            return BLACK
        else:
            return WHITE

    # Sets the turn for the board
    def setTurn(self,turn):
        self.turn = turn

    # Toggles the turn between the two colors
    def toggleTurn(self):
        self.turn = self.getOppositeColor(self.turn)

    # Sets the value of a specific square
    def setSquare(self,piece,x,y):
        self.squares[x][y] = piece

    # Returns the value at a given square
    def getSquare(self,x,y):
        return self.squares[x][y]

    # Set full board state by passing in a fully configured board array. Will only work if
    # the size of the given board matches the size of the board that the object was instantiated to
    def setBoard(self,bd):
        if (len(bd) != self.size) or (len(bd[0]) != self.size):
            return -1
        else:
            self.squares = bd
            return 0

    # Returns the board array. This can be saved elsewhere and passed back in to .setBoard(board)
    # in order to revert to an earlier state
    def getBoard(self):
        return self.squares

    # Returns an array of coordinates listing all the pieces of a given color
    def getPieces(self,color):
        pieces=[]
        for i in range(self.size):
            for j in range(self.size):
                if (self.squares[j][i] == color) or ( (color == WHITE) and (self.squares[j][i] == KING) ):
                    pieces.append([j,i])
        return pieces

    # Generates an array of valid moves for a specific piece. Returns [] if there are no valid moves or if the selected square is empty
    def getMoves(self,x,y):
        if self.getSquare(x,y) == EMPTY:
            return []

        moves = []
        
        x_index = x - 1
        y_index = y
        while (x_index >= 0) and (self.getSquare(x_index,y_index) == EMPTY):
            if ([x_index, y_index] != [5,5]) and ((([x_index, y_index] != [0,10]) and ([x_index, y_index] != [10,0]) and ([x_index, y_index] != [0,0]) and ([x_index, y_index] != [10,10])) or self.getSquare(x,y) == KING): 
                moves.append([x,y,x_index,y_index])
            x_index -= 1

        x_index = x + 1
        while (x_index <= 10) and (self.getSquare(x_index,y_index) == EMPTY):
            if ([x_index, y_index] != [5,5]) and ((([x_index, y_index] != [0,10]) and ([x_index, y_index] != [10,0]) and ([x_index, y_index] != [0,0]) and ([x_index, y_index] != [10,10])) or self.getSquare(x,y) == KING): 
                moves.append([x,y,x_index,y_index])
            x_index += 1

        x_index = x
        y_index = y - 1
        while (y_index >= 0) and (self.getSquare(x_index,y_index) == EMPTY):
            if ([x_index, y_index] != [5,5]) and ((([x_index, y_index] != [0,10]) and ([x_index, y_index] != [10,0]) and ([x_index, y_index] != [0,0]) and ([x_index, y_index] != [10,10])) or self.getSquare(x,y) == KING): 
                moves.append([x,y,x_index,y_index])
            y_index -= 1

        y_index = y + 1
        while (y_index <= 10) and (self.getSquare(x_index,y_index) == EMPTY):
            if ([x_index, y_index] != [5,5]) and ((([x_index, y_index] != [0,10]) and ([x_index, y_index] != [10,0]) and ([x_index, y_index] != [0,0]) and ([x_index, y_index] != [10,10])) or self.getSquare(x,y) == KING): 
                moves.append([x,y,x_index,y_index])
            y_index += 1

        return moves

    # Returns the color of a given piece. Used for easier comparison between a selected piece and the current turn
    def pieceToColor(self,piece):
        if piece == KING:
            return WHITE
        else:
            return piece

    # Generates an array of all valid moves for a given color in the format [[x_1,y_1,xnew_1,ynew_1],[x_2,y_2,xnew_1,ynew_1],...,[x_n,y_n,xnew_n,ynew_n]]
    def getMoveset(self,color):
        moveset = []
        pieces = self.getPieces(color)
        for i in range(len(pieces)):
            moves = self.getMoves(pieces[i][0],pieces[i][1])
            for j in range(len(moves)):
                moveset.append(moves[j])
        return moveset

    # Returns true only if the passed coordinates are a special square, these squares are the four corners and the middle square
    # There significance is that they cannot be moved to except by the king and can be used to capture pieces.
    def isSpecialSquare(self,x,y):
        if x == 5 and y == 5:
            return True
        elif (x == 0 or x == 10) and (y == 0 or y == 10):
            return True
        else:
            return False

    # Takes an 4 value array generated by getMoveset() or getMoves() and implements the move. Performs incomplete move validation as well
    # Seriously, this method checks for some things, but not for others. Don't count on it to only implement correct moves
    def makeMove(self,move):
        oldSquare = self.getSquare(move[0],move[1])
        newSquare = self.getSquare(move[2],move[3])
        
        if oldSquare == EMPTY:
            print "Nothing to move"
            return -1

        if newSquare != EMPTY:
            print "Something's in the way"
            return -1

        if (move[0] != move[2]) and (move[1] != move[3]):
            print "That's a diagonal"
            return -1

        if (oldSquare != self.turn) and (not(self.turn == WHITE and oldSquare == KING)):
            print "Its not that pieces turn"
            return -1

        self.setSquare(EMPTY,move[0],move[1])
        self.setSquare(oldSquare,move[2],move[3])

        x = move[2]
        y = move[3]

        if x <= 8:
            if ( self.isSpecialSquare(x+2,y) or self.pieceToColor(self.getSquare(x+2,y)) == self.turn ) and self.getSquare(x+1,y) == self.getOppositeColor(self.turn):
                self.setSquare(EMPTY,x+1,y)
        if x >= 2:
            if ( self.isSpecialSquare(x-2,y) or self.pieceToColor(self.getSquare(x-2,y)) == self.turn ) and self.getSquare(x-1,y) == self.getOppositeColor(self.turn):
                self.setSquare(EMPTY,x-1,y)
        if y <= 8:
            if ( self.isSpecialSquare(x,y+2) or self.pieceToColor(self.getSquare(x,y+2)) == self.turn ) and self.getSquare(x,y+1) == self.getOppositeColor(self.turn):
                self.setSquare(EMPTY,x,y+1)
        if y >= 2:
            if ( self.isSpecialSquare(x,y-2) or self.pieceToColor(self.getSquare(x,y-2)) == self.turn ) and self.getSquare(x,y-1) == self.getOppositeColor(self.turn):
                self.setSquare(EMPTY,x,y-1)

        return 0

    # Prints out a string corresponding to which piece is passed in. Used for debugging.
    def printPiece(self,piece):
        if piece == EMPTY:
            print "Empty"
        elif piece == WHITE:
            print "White"
        elif piece == BLACK:
            print "Black"
        elif piece == KING:
            print "King"
        else:
            print "Not a piece"

    # AI makes a random move out of the set of valid moves for the color that currently has the turn
    def aiTakeTurnRandom(self):
        moveset = self.getMoveset(self.turn)
        choice = random.randint(0,len(moveset)-1)
        self.makeMove(moveset[choice])
        self.toggleTurn()
        return moveset[choice]

    # Returns the coordinates of the king
    def findKing(self):
        for i in range(11):
            for j in range(11):
                if (self.squares[j][i] == KING):
                    return [j,i]
        print "Something went terribly wrong"
        return "shit"
        
    
    # Returns all adjacent squares to the king. Used for checking for win conditions and for
    # finding good moves for black
    def getKingSides(self):
        kingSides = []
        kingLoc = self.findKing()
        if kingLoc[0] > 0:
            kingSides.append([kingLoc[0]-1,kingLoc[1]])
        if kingLoc[0] < 10:
            kingSides.append([kingLoc[0]+1,kingLoc[1]])
        if kingLoc[1] > 0:
            kingSides.append([kingLoc[0],kingLoc[1]-1])
        if kingLoc[1] < 10:
            kingSides.append([kingLoc[0],kingLoc[1]+1])
        return kingSides

    def findCaptureMoves(self,moveset):
        color = self.pieceToColor(self.getSquare(moveset[0][0],moveset[0][1]))
        capture_moveset = []

        for i in range(len(moveset)):
            x = moveset[i][2]
            y = moveset[i][3]

            if x <= 8:
                if ( self.isSpecialSquare(x+2,y) or self.pieceToColor(self.getSquare(x+2,y)) == self.turn ) and self.getSquare(x+1,y) == self.getOppositeColor(self.turn):
                    capture_moveset.append(moveset[i])
            if x >= 2:
                if ( self.isSpecialSquare(x-2,y) or self.pieceToColor(self.getSquare(x-2,y)) == self.turn ) and self.getSquare(x-1,y) == self.getOppositeColor(self.turn):
                    capture_moveset.append(moveset[i])
            if y <= 8:
                if ( self.isSpecialSquare(x,y+2) or self.pieceToColor(self.getSquare(x,y+2)) == self.turn ) and self.getSquare(x,y+1) == self.getOppositeColor(self.turn):
                    capture_moveset.append(moveset[i])
            if y >= 2:
                if ( self.isSpecialSquare(x,y-2) or self.pieceToColor(self.getSquare(x,y-2)) == self.turn ) and self.getSquare(x,y-1) == self.getOppositeColor(self.turn):
                    capture_moveset.append(moveset[i])
                    
        return capture_moveset



    # The AI attempts to make a winning move or a simplistically good move. Otherwise it makes a random move.
    def aiTakeTurnBasic(self):
        full_moveset = self.getMoveset(self.turn)
        better_moveset = []
        okay_moveset = []
        capture_moveset = self.findCaptureMoves(full_moveset)

        # If its white's turn, check to see if you can move your king to a corner and then do that. Then see if you can move to an edge
        # If you can't do that either, make a random move
        if(self.turn == WHITE):
            for i in range(len(full_moveset)):
                if full_moveset[i][0:2] == self.findKing():
                    if (full_moveset[i][2] == 0 or full_moveset[i][2] == 10) and (full_moveset[i][3] == 0 or full_moveset[i][3] == 10):
                        better_moveset.append(full_moveset[i])
                    elif full_moveset[i][2] == 0 or full_moveset[i][2] == 10 or full_moveset[i][3] == 0 or full_moveset[i][3] == 10:
                        okay_moveset.append(full_moveset[i])
            if better_moveset != []:
                choice = random.randint(0,len(better_moveset)-1)
                self.makeMove(better_moveset[choice])
                self.toggleTurn()
                return better_moveset[choice]
            elif capture_moveset != []:
                choice = random.randint(0,len(capture_moveset)-1)
                self.makeMove(capture_moveset[choice])
                self.toggleTurn()
                return capture_moveset[choice]
            elif okay_moveset != []:
                choice = random.randint(0,len(okay_moveset)-1)
                self.makeMove(okay_moveset[choice])
                self.toggleTurn()
                return okay_moveset[choice]
            else:
                choice = random.randint(0,len(full_moveset)-1)
                self.makeMove(full_moveset[choice])
                self.toggleTurn()
                return full_moveset[choice]
                
        # If its black's turn, try to get your junk next to the king. If you can't, make a random move
        else:
            kingSides = self.getKingSides()
            for i in range(len(full_moveset)):
                for j in range(len(kingSides)):
                    if full_moveset[i][2:4] == kingSides[j]:
                        print "Found a good move"
                        print full_moveset[i][2:4]
                        print kingSides[j]
                        better_moveset.append(full_moveset[i])
            if better_moveset == []:
                choice = random.randint(0,len(full_moveset)-1)
                self.makeMove(full_moveset[choice])
                self.toggleTurn()
                return full_moveset[choice]
            elif capture_moveset != []:
                choice = random.randint(0,len(capture_moveset)-1)
                self.makeMove(capture_moveset[choice])
                selt.toggleTurn()
                return capture_moveset([choice])
            else:
                choice = random.randint(0,len(better_moveset)-1)
                self.makeMove(better_moveset[choice])
                self.toggleTurn()
                return better_moveset[choice]
            

    # Make a move and toggles who has the turn. Use this method for passing in user inputed moves
    # WARNING! THIS FUNCTION DOES NOT CHECK FOR BLOCKING PIECES! IT CAN BE USED TO MAKE ILLEGAL MOVES
    def humanTakeTurn(self,move):
        if self.makeMove(move) == -1:
            print "Invalid Move"
        else:
            self.toggleTurn()
