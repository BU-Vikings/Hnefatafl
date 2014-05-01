#!/usr/bin/python2

import random
import sys

# This module defines the board class. A board object contains a 2D array of values
# defined as 2 layers of lists, as in [[1,2],[3,4]]. The board also tracks turns and
# can be initialized to any size. If a size isn't defined, the board defaults to
# 11x11 and fills itself with a propperly set up hnefatafl board. Moves can be requested
# using the board.aiTakeTurnRandom() method and moves can be input using
# human.takeTurn(move). The input move should be a list of size four and contain the
# values [x,y,new_x,new_y] where x and y are the coordinates of the piece to be moved
# and new_x and new_y are the coordinates of the square to be moved to. If these methods
# are used then the board will automatically track the turn and update it's own board state
# otherwise, an entirely new board can be passed in using board.setBoard(bd). This will
# reduce the chance of board state diverging, but if this method is used, be sure to call
# board.toggleTurn() or board.setTurn() to update what turn it is after each new write.

EMPTY = 0
WHITE = 1
BLACK = 2
KING = 3

class board:
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

    # Prints out the board
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

    # Sets the turn
    def setTurn(self,turn):
        self.turn = turn

    # Toggles the turn between the two colors
    def toggleTurn(self):
        if self.turn == WHITE:
            self.turn = BLACK
        else:
            self.turn = WHITE

    # Sets the value of a specific square
    def setSquare(self,piece,x,y):
        self.squares[x][y] = piece

    # Returns the value at a given square
    def getSquare(self,x,y):
        return self.squares[x][y]

    # Set full board state.
    def setBoard(self,bd):
        if (len(bd) != self.size) or (len(bd[0]) != self.size):
            return -1
        else:
            self.squares = bd
            return 0

    # Returns the array of squares
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

    # Generates an array of all valid moves for a given color
    def getMoveset(self,color):
        moveset = []
        pieces = self.getPieces(color)
        for i in range(len(pieces)):
            moves = self.getMoves(pieces[i][0],pieces[i][1])
            for j in range(len(moves)):
                moveset.append(moves[j])
        return moveset

    # Takes an 4 value array generated by getMoveset() or getMoves() and implements the move. Performs incomplete move validation as well
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
        return 0

    # AI makes a random move out of the set of valid moves for the color that currently has the turn
    def aiTakeTurnRandom(self):
        moveset = self.getMoveset(self.turn)
        choice = random.randint(0,len(moveset)-1)
        self.makeMove(moveset[choice])
        self.toggleTurn()
        return moveset[choice]

    # Finds the location of the king
    def findKing(self):
        for i in range(11):
            for j in range(11):
                if (self.squares[j][i] == KING):
                    return [j,i]
        print "Something went terribly wrong"
        return "shit"
        
    
    # Find the edges of the king
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


    # The AI trys to make a winning move, otherwise it makes a random move.
    def aiTakeTurnBasic(self):
        full_moveset = self.getMoveset(self.turn)
        better_moveset = []
        okay_moveset = []

        # If its white's turn, check to see if you can move your king to a corner and then do that. If you can't, make a random move
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
