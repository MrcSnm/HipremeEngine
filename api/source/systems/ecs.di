// D import file generated from 'source\systems\ecs.d'
module systems.ecs;
class HipComponent
{
	ulong owner;
}
class HipEntity
{
	ulong id;
	string tag;
	protected HipComponent[] components;
	HipComponent getComponent(T)()
	{
		return cast(T)components[i];
	}
}
class HipECS
{
}
