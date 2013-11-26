Game of Life
============

Sean Murphy
-----------

This is my first submission to IOCCC, so I apologize in advance for anything I screw up. That being said, I'm pretty sure my program is "simple" enough that there shouldn't be any problem. 

Compiling: 
----------
c99 yells some warnings at me but it and all other `-std=` that I tried work. I'm using Ubuntu 13 in a VM, but I've even gotten this to work with MinGW in Windows 7. However, it looks ugly in Windows. It should work on pretty much whatever as long as `usleep()` is accepted. 

Running: 
--------
You will want the terminal at 64x33 (33 lines and 64 glyphs per line) in size for best effect. Bigger will work in a pinch. Run the program and watch until you get bored. When bored, CTRL-C or escape somehow. Run it again for a different starting pattern.

The Output: 
-----------
I'm sure you all know Conway's Game of Life already. 

The Program: 
============
*SPOILERS BELOW*

`int main(){`
-------------
This part is pretty self-explanatory. However, it is worth noticing that I didn't have to include or define anything.


`int _[2048],O=(int)&O,__=~__+__;`
----------------------------------
Single underscore is a signed int array that holds the life cells. The 5th bit determines the current generation's aliveness. The 4th bit determines the next generation's aliveness. Bits 0-3 holds a count of neighbors. I could call it a byte/char/whatever, but then I'd need two lines of variable declaration. 

Capital O is our random number generator. I didn't want to use `rand()`, so I made my own. It's not cryptographically secure by any means, but it is random enough for this application, and it seeds differently each run of the program. Here's the magic: I assign `O` to the int cast of its address. This is a big number that should be different on each run, so it works nicely as a seed. 

Double underscore is an index variable. I abuse 2's complement math to initialize it as -1. Later this will be seen as `__+=~__`. Work the bits yourself if you'd like to see exactly how this happens. I really like bitwise math. 

`while((__=-~__)^2048)__[_]=(O=(O*0x41C64E6D+12345)&0x7fffffff)&1024?1<<5:0;`
-----------------------------------------------------------------------------
`yada = - ~yada` is equivalent to `++yada` because of 2's complement. This is then XOR'd with 2048 which is the length of single underscore. This will return non-zero until double underscore equals 2048. This indexes through the entire array of life cells. 

The rest of the line will make `O` the next random number in the pseudo-random series then set the 5th bit of the life cells with a 50% probability. 

`while(usleep('d'<<'\n'),__+=~__){`
-----------------------------------
`'d'<<'\n'` is about 100,000 which gives us 10 frames per second. 

Comma operators are fun because they are easily missed! I also like consolidated code.

The usleep return value is ignored in favor of the -1 returned by the assignment. -1 happens to be true, always, so this is a `while(1)`.


`while((__=-~__)^8192){`
------------------------
Double underscore starts as -1 and goes until 8191 which happens to be 4*2048
This gives us essentially a doubly nested for structure going from 0 to 2047 (rt shift index by 2) and from 0 to 3 (index modulo 4).

`if(_[((__>>2)+2048+"\x01?@A"[__%4])%04000]&1<<5)*(_+(__>>2))=-~_[__>>2];`
--------------------------------------------------------------------------
Compute neighbors and add count to lower 4 bits of life cell. 

Let's break this up some.
First, in a toroidally mapped game of life with a row length of 64, what are the relative addresses of the neighbor?
Plus and minus 1, 63, 64, 65. The plus and minus allows us to do nearly the same thing twice. Notice the next line, apart from using different bases for the number representations, only differs by one thing. A plus has been turned into a minus. 

Remember, we are using strange indexing. Every time you see `__>>2`, know we are using that as the array index. Every time you see `__%4`, that is our inner loop counter to go through the 8 neighbor addresses. 

`"\x01?@A"` has the values 1, 63, 64, 65. 

`"\x01?@A"[__%4]` selects one of these 4 numbers. This is the relative address of a neighbor.

`((__>>2)+2048+"\x01?@A"[__%4])` is the array index plus the relative address plus the array length. Adding the array length is necessary because `%` isn't modulo so much as it is a remainder operator. It would return negative values (on some systems) unless we added the array length. 

We now take the remainder of this and 04000 (which is octal for 2048, the array length). This is our wraparound. 

We now find the value of the array at this index and check to see if the 5th bit is set. This is the argument of the if statement. This boils down to "for each possible neighbor, if the neighbor is currently alive then do:"

`*(_+(__>>2))=-~_[__>>2]`
We add the address of the array to our index, dereference that to get the life cell value, and add one to it. I could have used square brackets instead, but where's the fun in that? Also, more bitwise math. Can you tell I like bitwise math? (I'm used to 8-bit microcontrollers and direct hardware access.)

So, what we have done here with this line and the next is add in the total neighbor count to each cell.

`if(__%4==3)_[__>>2]|=_[__>>2]^'\"'&&_[__>>2]^'#'?((_[__>>2]^3)?0:1<<4):1<<4;};`
--------------------------------------------------------------------------------
If we are on the 4th set of neighbor addresses, we have finished counting neighbors for that life cell. This is when we can determine the state of the cell in the next generation. 

`_[__>>2]`
In C, taking an index at an array is the same as taking an array at an index. 

Next is "bitwise or becomes" which allows us to set bits without disturbing the rest of the array.

Now comes a doubly nested ternary statement. Evil, I know. 

In ASCII, `3 + (1<<5)` (three neighbors and currently alive) is `'#'`, two neighbors and currently alive is `'\"'`, three neighbors and currently dead is `3`. Inside the ternary statements are comparisons against these conditions. When one is found, the 4th bit in the current life cell is set. Otherwise, nothing happens. 

We have now successfully determined the state of each cell for the next generation. 

`while((__=-~__)^10240)if(putchar((_[__%2048]=_[__%2048]<<1&1<<5)?'X':' '),!(63^__%0100))putchar(10);}};`
----------------------------------------------------------------------------------------------------------
Now, we loop until 10240 from our current index variable value of 8192. When we modulo by 2048 (or 0100), we loop through the entire array. It would take an extra line to reset double underscore to -1, and I didn't want to take the space. 

`_[__%2048]=_[__%2048]<<1&1<<5)`
This left shifts the life cell and clears all but the 5th bit. This is when we actually step to the next generation. When used as an r-value, it will return true when the new generation is alive and false when the new generation is dead. Couple this with a ternary in `putchar` and we output an X for a live cell and a space for a dead cell.

Now, ignore this with a comma operator. 

`!(63^__%0100)` is true at the end of each line. This gets evaluated by the if statement which causes a `putchar(10)` at the end of each line. 10 is a newline character. 

Program execution now returns to our `while(1)` and, after a 0.1s delay, continues with the next generation. This continues until you get bored and halt the program. 

