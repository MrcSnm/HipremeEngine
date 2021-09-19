// D import file generated from 'source\hiprenderer\backend\sdl\texture.d'
module hiprenderer.backend.sdl.texture;
import hiprenderer.renderer;
import hiprenderer.texture;
import data.image;
import bindbc.sdl;
public class Hip_SDL_Texture : ITexture
{
	SDL_Texture* data;
	public void setWrapMode(TextureWrapMode mode);
	public void bind();
	public void unbind();
	public void bind(int slot);
	public void unbind(int slot);
	public bool load(Image img);
	void setTextureFilter(TextureFilter mag, TextureFilter min);
	void dispose();
}
