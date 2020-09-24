module global.assets;
public class Assets
{
	public static class Graphics
	{
		public enum Sprites: string
		{
			teste_bmp = "assets\\graphics\\sprites\\teste.bmp"
		}
	}
	public enum Audio : string
	{
		active_matrix_edited_wav = "assets/audio/active_matrix_edited.wav",
		the_sound_of_silence_wav = "assets/audio/the-sound-of-silence.wav",
		junkyard_a_class_mp3 = "assets/audio/junkyard-a-class.mp3"
	}
}