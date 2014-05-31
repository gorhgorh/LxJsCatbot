/* Simple test initiate a catbot with repl, injected objects are : laser, onlineLed, servoX, servoY */

var catbot    	= require('catbot'),
	temporal		= require('temporal');

catbot(function (err,hard) {
	if (!hard) {
      throw new Error('did you turn it on and off ?');
    }

    // all centered 
    hard.x.center();
    hard.y.center();

    temporal.queue([
		{
			delay: 2000,
			task: function() {
	    		hard.x.sweep();
	    		hard.y.sweep();
			}
		},
		{
			delay: 6000,
			task: function() {
		  	hard.x.stop();
    		hard.y.stop();
		  	hard.x.center();
    		hard.y.center();
    		console.log('sweep done !');
			}
		}
	]);
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