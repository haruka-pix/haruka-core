extends Node

var music : AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var volume_normalized := 0.8

const MAX_SFX_PLAYERS := 8

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	for i in MAX_SFX_PLAYERS:
		var sfx = AudioStreamPlayer.new()
		sfx.bus = "SFX"
		add_child(sfx)
		sfx_players.append(sfx)

func set_volume(channel:String, vol:float) -> void:
	volume_normalized = clamp(vol, 0.0, 1.0)
	var db: int
	var idx = AudioServer.get_bus_index(channel)
	AudioServer.set_bus_mute(idx, false)
	if vol <= 0.001:
		AudioServer.set_bus_mute(idx, true)
	else: 
		db = linear_to_db(volume_normalized)
		AudioServer.set_bus_volume_db(idx, db)

#Music
func play(path: String, loop = false) -> void: 
	var stream = load(path)
	music.stream = stream
	music.stream.loop = loop
	music.play()
func stop() -> void:
	if music:
		music.stop()
func pause() -> void:
	if music:
		music.stream_paused = true
func resume() -> void:
	if music:
		music.stream_paused = false
func is_playing() -> bool:
	return music and music.playing
func get_time() -> float:
	if music:
		return music.get_playback_position()
	return 0.0
func get_music_volume() -> float:
	return volume_normalized


#SFX
func play_sfx(path: String) -> void: 
	var stream = load(path)
	for sfx in sfx_players:
		if not sfx.playing:
			sfx.stream = stream
			sfx.play()
			return
	print("SFX channels at max")
func get_sfx_volume() -> float:
	var idx = AudioServer.get_bus_index("SFX")
	var db = AudioServer.get_bus_volume_db(idx)
	return db_to_linear(db) 
