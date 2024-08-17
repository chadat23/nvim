import gtts
import sys

text = sys.argv[1]

tts = gtts.gTTS(text)

tts.save("/tmp/sound.mp3")

