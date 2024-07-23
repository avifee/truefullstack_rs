#![no_main]
#![no_std]

use core::{hint, panic::PanicInfo};

use self::sys::exit;

pub mod sys;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    exit(1)
}

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {
        hint::spin_loop();
    }
}
