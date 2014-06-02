/* Simple test to boot the catbot, center servos, pause, sweep, stops. */

var catbot      = require('catbot')({port: '/dev/cu.usbmodem1411'}),
    temporal    = require('temporal');

catbot(function (err,hard) {
    if (!hard) {
      throw new Error('did you turn it on and off ?');
    }
    hard.rst();

    temporal.queue([
        {
            delay: 2000,
            task: function() {
                hard.online.on();
                hard.y.to(0);
                 setTimeout(function  () {hard.laser.on();
                     // body...
                 }, 800);
                //hard.laser.on();
                console.log('now your laser should point down and light up, online led is on as well');
            }
        },
        {
            delay: 2000,
            task: function() {
                console.log('now your servos sweeps');
                hard.laser.off();
                hard.x.sweep();
                hard.y.sweep();
            }
        },
        {
            delay: 6000,
            task: function() {
                hard.rst();
                console.log('sweep done !, your cat remote is ready to go sir');
            }
        },
        {
            delay: 1000,
            task: function() {
                process.exit();
            }
        }

    ]);
});

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
