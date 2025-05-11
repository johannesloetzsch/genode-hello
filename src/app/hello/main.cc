#include <base/component.h>
#include <base/log.h>

void Component::construct(Genode::Env &)
{
    while(true) {
	Genode::log("Hello world");
	Genode::log("press Ctrl+A X to quit qemu\n");
    }
}
