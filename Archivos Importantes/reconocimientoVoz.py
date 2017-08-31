#!/usr/bin/env python3


import speech_recognition as sr
import json
import socket


# Conexion con socket

cliente = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
cliente.connect(("0.0.0.0",55555))

# obtain audio from the microphone
while(1):
	r = sr.Recognizer()
	with sr.Microphone() as source:
	    print("Di algo!")
	    audio = r.listen(source)


	frases = ["arriba","abajo","avanza","retrocede","derecha","izquierda","aterriza"]
	# recognize speech using Google Cloud Speech

	with open(r"/home/emiliomarin/ReconocimientoVoz/credentials.json","r") as f:
	#with open('~/ReconocimientoVoz/credentials.json') as f:
		#GOOGLE_CLOUD_SPEECH_CREDENTIALS = r"""INSERT THE CONTENTS OF THE GOOGLE CLOUD SPEECH JSON CREDENTIALS FILE HERE"""
		GOOGLE_CLOUD_SPEECH_CREDENTIALS = f.read()
		print(f.read())
	
	try:
	    rec = r.recognize_google_cloud(audio, credentials_json=GOOGLE_CLOUD_SPEECH_CREDENTIALS, language = "es-ES", preferred_phrases = frases)
	    print("Google Cloud Speech cree que has dicho " + rec)
	except sr.UnknownValueError:
	    print("Google Cloud Speech no pude entender el audio")
	except sr.RequestError as e:
	    print("Could not request results from Google Cloud Speech service; {0}".format(e))

	# Comprobar el resultado para saber que comando enviar
	comando = ""
	rec = rec.lower()
	rec = rec.strip()
	print("rec = " + rec)

	if rec == "subir" :
		comando = "i"
	elif rec == "bajar" :
		comando = "k"
	elif rec == "avanza" :
		comando = "w"
	elif rec == "retrocede" :
		comando = "s"
	elif rec == "derecha" :
		comando = "d"
	elif rec == "izquierda" :
		comando = "a"
	elif rec == "aterriza" :
		comando = "z"




	# Envio al socket

	print("Comando = " + comando)
	cliente.send(comando)

