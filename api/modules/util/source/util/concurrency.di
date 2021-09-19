// D import file generated from 'source\util\concurrency.d'
module util.concurrency;
template concurrent(string func)
{
	mixin(func);
	mixin("shared " ~ func);
}
struct Atomic(T)
{
	import core.atomic;
	private T value;
	auto opAssign(T)(T value)
	{
		atomicStore(this.value, value);
		return value;
	}
	private @property T v()
	{
		return atomicLoad(value);
	}
	alias v this;
}
struct Volatile(T)
{
	import core.volatile;
	private T value;
	auto synchronized opAssign(T)(T value)
	{
		volatileStore(&this.value, value);
		return value;
	}
	private synchronized @property T v()
	{
		return volatileLoad(value);
	}
	alias v this;
}
