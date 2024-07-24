#![no_main]
#![no_std]

use core::{hint, panic::PanicInfo};

use self::sys::{exit, write};

pub mod sys;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    write(1, "Hello, world!\n".as_bytes()).unwrap(); //1 is stdout
    exit(0)
}

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    exit(1); //not sure if I can call syscalls in the panic handler tho...
    #[allow(unreachable_code)] //just in case
    loop {
        hint::spin_loop();
    }
}
