import serial
import io

ser = serial.Serial(port='COM3', baudrate=921600, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, timeout=1)
while (1):
	board = ser.readline()
	if (len(board) > 0):
		if (ord(board[0]) == 240):
			print "board detected: " + board[1:]