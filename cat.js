/* Simple test to boot the catbot, center servos, pause, sweep, stops. */

var catbot      = require('catbot'),
    temporal    = require('temporal'),
    reset;

catbot(function (err,hard) {
    if (!hard) {
      throw new Error('did you turn it on and off ?');
    }
    reset=function(){
            hard.x.stop();
            hard.y.stop();
            hard.x.center();
            hard.y.center();
        };
    // all centered
    reset();

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
                reset();
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
