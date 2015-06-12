
class Game_System
  #--------------------------------------------------------------------------
  # * Play Background Music
  #     bgm : background music to be played
  #--------------------------------------------------------------------------
  def bgm_play(bgm, pos = 0)
		bgm = RPG::AudioFile.new(bgm) unless bgm.is_a?(RPG::AudioFile)
    @playing_bgm = bgm
    if bgm != nil and bgm.name != ""
      Audio.bgm_play(bgm.name, 0, bgm.pitch, pos)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
end



