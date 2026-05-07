#include <stdio.h>
#include <stdlib.h>
#include "support.h"
#include "phases.h"

FILE *infile;

int main(int argc, char *argv[])
{
    char *input;


    /* When run with no arguments, the bomb reads its input lines 
     * from standard input. */
    if (argc == 1) {  
	infile = stdin;
    } 

    /* When run with one argument <file>, the bomb reads from <file> 
     * until EOF, and then switches to standard input. Thus, as you 
     * defuse each phase, you can add its defusing string to <file> and
     * avoid having to retype it. */
    else if (argc == 2) {
	if (!(infile = fopen(argv[1], "r"))) {
	    printf("%s: Error: Couldn't open %s\n", argv[0], argv[1]);
	    exit(8);
	}
    }

    /* You can't call the bomb with more than 1 command line argument. */
    else {
	printf("Usage: %s [<input_file>]\n", argv[0]);
	exit(8);
    }

    /* The practice bomblab starts here. */
    printf("\nOh no! Prof.Hsu plans to spread his bombs everywhere!\n");
    printf("And it will be up to YOU guys to defuse the bombs and save our machines!\n");
    printf("I thereby provide you a practice bomb to ready you for Prof.Hsu's scheme.\n");
    printf("It only has 2 phases to get you familiar with RISC-V assembly and gdb.\n\n");

    /* First phase: The simplest I can think of! */
    input = read_line();             /* Get input          */
    phase_1(input);                  /* Run the phase      */
    phase_defused();                 /* Congratulations!   */

    printf("Phase 1 defused! Keep up with the good work!\n\n");

    /* Second phase: Gets you familiar with function parameter passing and 
                     relative address calculation in RISC-V */
    input = read_line();
    phase_2(input);
    phase_defused();

    printf("\nAnd that is the end of the practice bomblab.\n");
    printf("Hopefully you are now better prepared for the actual lab :p\n");
    printf("If you have any questions or wish to report any bugs, please\n");
    printf("contact the TA Team.\n");
    
    return 0;
}
