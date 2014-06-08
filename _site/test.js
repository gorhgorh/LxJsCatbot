/* Simple test initiate a catbot with repl, injected objects are : laser, onlineLed, servoX, servoY, reset */

var catbot      = require('catbot');

catbot(function (err,hard) {
    if (!hard) {
      throw new Error('did you turn it on and off ?');
    }

    hard.rst(); // stops and center the servos

})

//           \`*-.
//            )  _`-.
//           .  : `. .
//           : _   '  \
//           ; *` _.   `*-._
//           `-.-'          `-.
//             ;       `       `.
//             :.       .        \
//             . \  .   :   .-'   .
//             '  `+.;  ;  '      :
//             :  '  |    ;       ;-.
//             ; '   : :`-:     _.`* ;
//          .*' /  .*' ; .*`- +'  `*'
// .        `*-*   `*-*  `*-*'
