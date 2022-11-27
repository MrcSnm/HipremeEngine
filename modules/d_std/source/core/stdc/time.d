module core.stdc.time;
import core.stdc.config;


alias time_t = c_long;
time_t  time(scope time_t* timer) nothrow;
