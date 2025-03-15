// #![no_main]
#![no_std]
#![feature(lang_items, start)]

// extern crate alloc;
// use alloc::{boxed::Box, string::String};
use core::{
    // alloc::{GlobalAlloc, Layout},
    panic::PanicInfo,
};

use self::sys::{
    // alloc::ALLOCATOR,
    exit,
    write,
};

pub mod sys;

#[lang = "start"]
fn lang_start<T>(main: fn() -> T, argc: isize, argv: *const *const u8, sigpipe: u8) -> isize {
    main();
    12
}

fn main() {
    let _ = write(1, b"hi");
}

// #[no_mangle]
// pub extern "C" fn _start() -> ! {
//     unsafe {
//         let ptr = ALLOCATOR.alloc_zeroed(Layout::from_size_align(1, 1).unwrap());
//         *ptr = u8::MAX;
//     }
//     let a = Box::new(b'a');
//     let b = *a + 1;
//     // let e = String::from("Hello from the heap!\n");
//     write(1, "Hello, world!\n".as_bytes()).unwrap(); //1 is stdout
//     write(1, &[b]).unwrap();
//     exit(0)
// }

//panicking causes a segfault before it even reaches the panic function
//so this is mostly to appease the compiler
#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    write(1, "panicked!\n".as_bytes()).unwrap(); //1 is stdout
    exit(255);
}
