#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "phases.h"
#include "support.h"

#define ANSWER_STR "Genshin Impact makes me happy and Mini World makes my day."


/* phase 1: Comparing two strings */
void phase_1(char *input) {

    if (strcmp(input, ANSWER_STR) != 0)
        explode_bomb();

}


/* phase 2: A simple switch statement that does some arithmatic/logic calculations.
            Students can have multiple correct answers depending on the index chosen */
void phase_2(char *input) {

    int numbers[4];
    read_four_ints(input, numbers);
    int result;

    int x = numbers[0];     		// The 1st user input must be 10: binary 1010
    int y = numbers[1];     		// The 2nd user input muse be 12: binary 1100
	int index = numbers[2];			// The 3rd user input is used as the index
	int user_answer = numbers[3];	// The 4th user input is the corresponding result

	if (x != 10 || y != 12)
		explode_bomb();

    switch(index) {
		case 0:
			result = x + y;	    	// 22
			break;
		case 1:
			result = x - y;			// -2
			break;
		case 2:
			result = x * y;			// 220
			break;
		case 3:
			result = x & y;	    	// 8,  binary 1000
			break;
		case 4:
			result = x | y;	    	// 14, binary 1110
			break;
		case 5:
			result = x ^ y;	    	// 6,  binary 0110
			break;
		default:
			explode_bomb();
    }

    if (user_answer != result)
        explode_bomb();

}
