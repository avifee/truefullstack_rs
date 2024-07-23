#![no_main]
#![no_std]

use core::{hint, panic::PanicInfo};

#[no_mangle]
pub extern "C" fn _start() -> ! {
    loop {
        hint::spin_loop();
    }
}

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {
        hint::spin_loop();
    }
}
