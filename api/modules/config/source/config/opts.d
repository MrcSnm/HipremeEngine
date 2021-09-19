
module config.opts;
enum HIP_DEBUG = true;
enum HE_NO_LOG = false;
enum HE_ERR_ONLY = false;
enum HIP_OPTIMIZE = false;
enum HIP_OPENSLES_OPTIMAL = true;
enum HIP_OPENSLES_FAST_MIXER = false;
static if (HIP_OPENSLES_FAST_MIXER)
{
	static assert(HIP_OPENSLES_OPTIMAL, "Can't use OpenSL ES fast mixer without using its optimal \x0abuffer size and sample rate");
}
