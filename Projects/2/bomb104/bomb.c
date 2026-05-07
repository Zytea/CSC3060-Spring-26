/***************************************************************************
 * Dr. Lethal's Insidious Bomb, Version 0.1
 * Copyright 2024, Dr. Lethal Incorporated. All rights reserved.
 *
 * LICENSE:
 *
 * Dr. Lethal Incorporated (the PERPETRATOR) hereby grants you (the
 * VICTIM) explicit permission to use this bomb (the BOMB).  This is a
 * time limited license, which expires on the death of the VICTIM.
 * The PERPETRATOR takes no responsibility for damage, frustration,
 * insanity, bug-eyes, carpal-tunnel syndrome, loss of sleep, or other
 * harm to the VICTIM.  Unless the PERPETRATOR wants to take credit,
 * that is.  The VICTIM may not distribute this bomb source code to
 * any enemies of the PERPETRATOR.  No VICTIM may debug,
 * reverse-engineer, run "strings" on, decompile, decrypt, or use any
 * other technique to gain knowledge of and defuse the BOMB.  BOMB
 * proof clothing may not be worn when handling this program.  The
 * PERPETRATOR will not apologize for the PERPETRATOR's poor sense of
 * humor.  This license is null and void where the BOMB is prohibited
 * by law.
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "support.h"
#include "phases.h"

/* 
 * Note to self: Remember to erase this file so my victims will have no
 * idea what is going on, and so they will all blow up in a
 * spectaculary fiendish explosion. -- Dr. Lethal 
 */

FILE *infile;

int main(int argc, char *argv[])
{
    char *input;

    /* Note to CUHK: remember to port this bomb to RISC-V and put a 
     * fantastic spin on it. :) [DONE] */

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

    /* Do all sorts of secret stuff that makes the bomb harder to defuse. */
    initialize_bomb();

    printf("Wassup ladies and lads! This is Prof. Hsu\n");
    printf("Welcome to my malevolent little bomb. Wanna blow yourselves up?\n");
    printf("You have 6 phases to deal with if you want to live, Eh ha ha ha ha!");
    printf("Good luck, OR NOT! *evil laugh* \n");

    /* Hmm...  Six phases must be more secure than one phase! */
    input = read_line();             /* Get input                   */
    phase_1(input);                  /* Run the phase               */
    phase_defused();                 /* Drat! You figured it out!   */
    printf("Phase 1 defused! Seems like this might be too easy?\n");

    /* Oh yeah? Well, how good is your math? Try this saucy problem! */
    input = read_line();
    phase_2(input);
    phase_defused();
    printf("That's number 2! Wonder if you can keep going...\n");

    /* I guess this is too easy so far. Let's see if some more complex code 
     * will trip you up! */
    input = read_line();
    phase_3(input);
    phase_defused();
    printf("DRAT! You're halfway there!\n");

    /* The fourth phase is twisty! No one will ever figure out how to defuse this... */
    input = read_line();
    phase_4(input);
    phase_defused();
    printf("Oh no! You got that one too! How about this one?\n");
    
    /* Round and 'round in memory we go, where we stop, the bomb blows! */
    input = read_line();
    phase_5(input);
    phase_defused();
    printf("Only one left! You will NEVER be able to solve this :3\n");

    /* This phase will never be used, since no one will get past the
     * earlier ones. But just in case, this one comes EXTRA hard */
    input = read_line();
    phase_6(input);
    phase_defused();

    /* Wow, you did it! But isn't something... missing? Perhaps... 
     * Something you overlooked? Mua ha ha ha ha! */
    
    return 0;
}
