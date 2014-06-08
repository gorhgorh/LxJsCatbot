/* Simple test to boot the catbot, center servos, pause, sweep, stops. */

var catbot      = require('catbot'),
    temporal    = require('temporal');

/**
 * Let's instanciate our catbot !
 * @param  {string} err  error message if any encountered
 * @param  {object} hard th
 * @return {functions} see catbot module info for available functions
 */

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
                setTimeout(function  () { hard.laser.on() }, 800);
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
    ]); // end temporal loop
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
