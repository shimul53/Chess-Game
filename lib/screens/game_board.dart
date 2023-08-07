import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';

import '../components/dead_piece.dart';
import '../helper/helper_methods.dart';
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {

  // A 2-dimensional list representing the chessboard,with each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

  //The currently selected piece on the chess board
  //if no piece is selected, this is null
  ChessPiece? selectedPiece;

  //the row index of the selected piece
  //default value -1 indicated no piece is currently selected
  int selectedRow = -1;

  //the row index of the selected piece
  //default value -1 indicated no piece is currently selected
  int selectedCol= -1;

  //A list of valid moves for the currently selected piece
  //each move is represented as a list with 2 elements row and column
  List<List<int>> validMoves = [];
  
  //A list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  //A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  //A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  //INITIAL POSITION OF KINGS (KEEP TRACK OF THIS TO MAKE IT EASIER LATER TO SEE IF KING IS IN CHECK
  List<int> whiteKingPosition = [7,4];
  List<int> blackKingPosition = [0,4];
  bool checkStatus = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeBoard();
  }
  //initialize board
  void _initializeBoard(){
    //initialize the board with nulls,meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8,(index) => null));

    //place random piece in middle to test
    //newBoard[3][3] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: "assets/images/king.png");


    //Place pawns
    for(int i = 0; i<8; i++){
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: "assets/images/pawn.png");
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: "assets/images/pawn.png");
    }
    //Place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png");
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png");
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png");
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png");

    //Place  Knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png");
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png");
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png");
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png");

    //Place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png");
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png");
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png");
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png");

    //Place queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: "assets/images/queen.png");

    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: "assets/images/queen.png");

    //Place kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: "assets/images/king.png");

    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: "assets/images/king.png");

    board = newBoard;

  }

  //user selected a piece
  void pieceSelected(int row , int col){
    setState(() {

      //No piece has been selected yet this is the first seletcion
      if(selectedPiece == null && board[row][col] != null){
        if(board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }

      }
      //there is a piece already selected, but user can select another one of their pieces
      else if(board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      //if there is a piece is selected and use taps on a square that is a valid move,move there
      else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);

      }

      //if a piece is selected , calculate it's valid moves
      validMoves = calculateRealValidMoves(selectedRow,selectedCol,selectedPiece,true);
    });
  }

  //calculate row valid moves
  List<List<int>> calculateRowValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> candidateMoves = [];

    if(piece == null){
      return  [];
    }

    //different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type){
      case ChessPieceType.pawn:
        //pawns can move forward if the square is not occupied
      if(isInBoard(row + direction, col) && board[row + direction][col] == null){
        candidateMoves.add([row + direction, col]);
      }

      //pawns can move 2 squares forward if they are at their initial positions
      if((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)){
        if(isInBoard(row + 2 * direction, col) &&
            board[row+2*direction][col] == null &&
            board[row + direction][col] == null){
          candidateMoves.add([row + 2 * direction, col]);
        }
      }
      //pawns can kill diagonally
      if(isInBoard(row + direction,col - 1) &&
          board[row + direction][col - 1] != null &&
          board[row + direction][col - 1]!.isWhite != piece.isWhite){
        candidateMoves.add([row + direction, col - 1]);
      }
      if(isInBoard(row + direction,col + 1) &&
          board[row + direction][col + 1] != null &&
          board[row + direction][col + 1]!.isWhite != piece.isWhite){
        candidateMoves.add([row + direction, col + 1]);
      }
        break;
      case ChessPieceType.rook:
        //horizontal and vertical directions
        var directions = [
          [-1,0], //up
          [1,0],  //down
          [0,-1], //left
          [0,1],  //right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow,newCol]); //kill
              }
              break; //blocked
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        //all eight position L shapes the knight can move
      var knightMoves = [
        [-2,-1],  //up 2 left 1
        [-2,1],  //up 2 right 1
        [-1,-2],  //up 1 left 2
        [-1,2],  //up 1 right 2
        [1,-2],  //down 1 left 2
        [1,2],  //down 1 right 2
        [2,-1],  //down 2 left 1
        [2,1],  //down 2 right 1
      ];
      for(var move in knightMoves){
        var newRow = row + move[0];
        var newCol = col + move[1];
        if(!isInBoard(newRow, newCol)){
          continue;
        }
        if(board[newRow][newCol] != null){
          if(board[newRow][newCol]!.isWhite != piece.isWhite){
            candidateMoves.add([newRow,newCol]); //capture
          }
          continue;  //blocked
        }
        candidateMoves.add([newRow,newCol]);
      }
        break;

      case ChessPieceType.bishop:
        //diagonal directions
        var directions = [
          [-1,-1], //up left
          [-1,1],  //up right
          [1,-1], //down left
          [1,1],  //down right
        ];

        for(var direction in directions){
          var i = 1;
          while(true){
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow,newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                candidateMoves.add([newRow,newCol]); //capture
              }
              break;  //block
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        //all eight directions: up, down, left, right and 4 diagonals
      var directions =[
        [-1,0],  //up
        [1,0],  //down
        [0,-1], //left
        [0,1], //right
        [-1,-1], //up left
        [-1,1], //up right
        [1,-1], //down left
        [1,1], //up right
      ];

      for(var direction in directions){
        var i = 1;
        while(true){
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if(!isInBoard(newRow,newCol)){
            break;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow,newCol]);  //capture
            }
            break;  //blocked
          }
          candidateMoves.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.king:
        //all eight directions
        var directions =[
          [-1,0],  //up
          [1,0],  //down
          [0,-1], //left
          [0,1], //right
          [-1,-1], //up left
          [-1,1], //up right
          [1,-1], //down left
          [1,1], //up right
        ];

        for(var direction in directions){
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if(!isInBoard(newRow, newCol)){
            continue;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMoves.add([newRow,newCol]);  //capture
            }
            continue;  //blocked
          }
           candidateMoves.add([newRow,newCol]);

        }
        break;
      default :

    }
    return candidateMoves;
  }

  //calculate real valid moves
  List<List<int>>  calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation){
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRowValidMoves(row,col, piece);

    //after generating all candidate moves, filter out any that would result in a check
    if(checkSimulation){
      for(var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];
        //this will simulate the future move to see if it's safe
        if(simulatedMoveIsSafe(piece!,row,col,endRow,endCol)){
          realValidMoves.add(move);
        }
      }

    }else{
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }


  //Move pieces
  void movePiece(int newRow, int newCol){
    
    //if the new spot has an enemy piece
    if(board[newRow][newCol] != null){
      //add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      }else{
        blackPiecesTaken.add(capturedPiece);
      }
    }

    //check if the piece being moved in a king
    if(selectedPiece!.type == ChessPieceType.king){
      //update the appropriate king pos
      if(selectedPiece!.isWhite){
        whiteKingPosition = [newRow, newCol];
      }else{
        blackKingPosition = [newRow , newCol];
      }
    }
    
  //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if any kings are under attack
    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    }else{
      checkStatus = false;
    }

    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    //check if it's check mate
    if(isCheckMate(!isWhiteTurn)){
      showDialog(context: context, builder: (context)=>
          AlertDialog(title: Text("CHECK MATE!"),actions: [
            //play again button
            TextButton(onPressed: resetGame, child: const Text("Play Again")),
          ],));
    }

    //change turns
    isWhiteTurn = !isWhiteTurn;
  }

  //is king in check?
  bool isKingInCheck(bool isWhiteKing){
    //get the position of the  king
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    //check if any enemy piece can attack the king
    for(int i = 0; i<8; i++){
      for(int j = 0; j< 8; j++){
        //skip empty squares and pieces of the same color as the king
        if(board[i][j] == null || board [i][j]!.isWhite == isWhiteKing){
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j],false);

        //check if the king's position is in this piece's valid moves
        if(pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])){
         return true;
        }
      }
    }
    return false;
  }

  //simulate a future move to see if it's safe (dose not put your own king under attack!
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow , int endCol){
     //save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //if the piece is the king , save it's current position and update to the new one
    List<int>? originalLKingPosition;
    if(piece.type == ChessPieceType.king){
      originalLKingPosition = piece.isWhite? whiteKingPosition : blackKingPosition;

      //update the king position
      if(piece.isWhite){
        whiteKingPosition = [endRow, endCol];

      }else{
        blackKingPosition = [endRow,endCol];
      }
    }

    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our own is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    //restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    //if the  piece was the king , restore it original position
    if(piece.type == ChessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalLKingPosition!;
      }else{
        blackKingPosition = originalLKingPosition!;
      }
    }
    //if king is in check =true , means it's not  a safe move. safe move= false
    return !kingInCheck;
  }

  //is it  check mate?
  bool isCheckMate(bool isWhiteKing){
    //if the king is not in check ,then it's  not check mate
    if(!isKingInCheck(isWhiteKing)){
      return false;
    }

    //if there is at least one legal move for any of the player's pieces, then it's not checkmate
    for(int i = 0; i<8; i++){
      for(int j = 0 ; j < 8; j++){
        //skip empty squares and pieces of the other color
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing ){
          continue;
        }
        List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);

        //if this piece has any valid moves, then it's not checkmate
        if(pieceValidMoves.isNotEmpty){
          return false;
        }
      }
    }

    //if none of the above conditions are met, then there are no legal moves left  to make
    //it's checkmate
    return true;

  }

  //Reset to new game
  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus =false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];
    isWhiteTurn = true;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [

          //White pieces taken
          Expanded(child: GridView.builder(
            itemCount: whitePiecesTaken.length,
            physics:const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemBuilder: (context,index)=> DeadPiece(imagePath: whitePiecesTaken[index].imagePath, isWhite: true,),
          ),
          ),

          //Game status
          Text(checkStatus? "CHECK!" : ""),
          
          //chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context,index){
                  //get the row and col position of this square
                  int row  = index ~/ 8;
                  int col = index % 8;

                  //check if this square is selected
                  bool isSelected = selectedRow == row && selectedCol == col;

                  //check if this square is a valid move
                  bool isValidMove = false;
                  for(var position in validMoves){
                    //compare row and col
                    if(position[0] == row && position[1] == col){
                      isValidMove = true;
                    }
                  }
                  return Square(
                      isWhite: isWhite(index),
                      piece: board[row][col],
                      isSelected: isSelected,
                      isValidMove: isValidMove,
                      onTap: ()=>pieceSelected(row,col),
                  );
                }),
          ),
          
          //black pieces taken
          Expanded(child: GridView.builder(
            itemCount: blackPiecesTaken.length,
            physics:const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemBuilder: (context,index)=> DeadPiece(imagePath: blackPiecesTaken[index].imagePath, isWhite: false,),
          ),
          ),
        ],
      ),
    );
  }
}
