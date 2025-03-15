//TODO: maybe abstract syscalls into special syscall functions

use core::{arch::asm, hint};

// pub mod alloc;

/// Execute the `exit(2)` syscall with status code defined by the `status` argument.
/// Refer to the [original docs](https://manpages.debian.org/unstable/manpages-dev/exit.2.en.html) for details
#[inline]
pub fn exit(status: usize) -> ! {
    unsafe {
        _exit(status);
    }
}

/// Execute the `exit(2)` syscall with status code defined by the `status` argument
///
/// # Safety
///
/// this function immediately terminates execution.
/// Refer to the [original docs](https://manpages.debian.org/unstable/manpages-dev/exit.2.en.html) for details
///
/// # Note
///
/// I initialy separated this and [exit] to implement [on_exit](https://manpages.debian.org/unstable/manpages-dev/on_exit.3.en.html),
/// but ended up not doing that because for most cases, [Drop] is enough.
#[inline]
pub unsafe fn _exit(status: usize) -> ! {
    asm!(
      "syscall",
      //60 is the id of the `exit` syscall
      //clobber return cause exit doesn't return anything
      inlateout("rax") 60usize => _,
      in("rdi") status,
      out("rcx") _, // rcx is used to store old rip
      out("r11") _, // r11 is used to store old rflags
      options(nostack, preserves_flags)
    );

    hint::unreachable_unchecked()
}

//TODO: set error variants
pub fn write(fd: usize, data: &[u8]) -> Result<usize, ()> {
    let mut ret: isize;
    unsafe {
        let ptr = data.as_ptr();
        let len = data.len();
        asm!(
            "syscall",
            inlateout("rax") 1usize => ret, //1 is write()
            in("rdi") fd,
            in("rsi") ptr,
            in("rdx") len,
            out("rcx") _, // rcx is used to store old rip
            out("r11") _, // r11 is used to store old rflags
            options(nostack, preserves_flags)
        );
    }
    if ret == -1 {
        Err(())
    } else {
        Ok(unsafe { ret.try_into().unwrap_unchecked() }) //Safety: it has been checked to be positive
    }
}
