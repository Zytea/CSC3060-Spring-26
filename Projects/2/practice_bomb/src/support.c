#include "support.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>

#define MAX_STRINGS        20
#define MAX_LINE           80

/* Global input stream defined by bomb.c */
extern FILE *infile;

/* Global that keeps track of the user's input strings */
char input_strings[MAX_STRINGS][MAX_LINE];
int num_input_strings = 0;

/* Return true if str is a blank line */
int blank_line(char *str)
{
    while (*str)
	if (!isspace(*str++))
	    return 0;
    return 1;
}

/* Read input lines until first non-blank or EOF encountered */
char *skip() 
{
    char *p;

    while (1) {
	p = fgets(input_strings[num_input_strings], MAX_LINE, infile);
	if ((p == NULL) || (!blank_line(p)))
	    return p;
    }
}

/* 
 * Read a line of input from stream "infile". There are a couple
 * of tricky aspects to this. First, we cut the students a little slack
 * by skipping over blank lines. Second, we allow partial solutions
 * to be read from a file before switching over to stdin.
 */
char *read_line(void)
{
    int len;
    char *str;

    /* switch over to stdin if we hit EOF on an input disk file */
    str = skip();
    if (str == NULL) { /* EOF */
        if (infile == stdin) { /* premature EOF on stdin */
            printf("Error: Premature EOF on stdin\n");
            exit(8);
        }
        else {
            infile = stdin; 
            str = skip();
            if (str == NULL) { /* premature EOF on stdin */
                printf("Error: Premature EOF on stdin\n");
                exit(0);
            }
        }
    }

    len = strlen(input_strings[num_input_strings]);
    if(len >= MAX_LINE-1) {
        printf("Error: Input line too long\n");
        strcpy(input_strings[num_input_strings++], "***truncated***");
        explode_bomb();
    }

    /* Strip off trailing newline: */
    input_strings[num_input_strings][len-1] = '\0';
    return input_strings[num_input_strings++];
}


/* Extract four ints from an input string */
 void read_four_ints(char *input, int *numbers)
{
  int numScanned = sscanf(input, "%d %d %d %d", 
                          numbers, numbers + 1, numbers + 2, numbers + 3);
  if (numScanned != 4)
    explode_bomb();
}

/* Oh no! The bomb went boom boom! */
void explode_bomb(void)
{
    printf("\n~~~~~~~~~~~~~~~~~~~~ BOMB EXPLODE ~~~~~~~~~~~~~~~~~~~~");
    printf("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    printf("\n~~~~~~~~~ ######    #####    #####    ## ##  ~~~~~~~~~");
    printf("\n~~~~~~~~~ #     #  #     #  #     #  # # # # ~~~~~~~~~");
    printf("\n~~~~~~~~~ ######   #     #  #     #  # # # # ~~~~~~~~~");
    printf("\n~~~~~~~~~ #     #  #     #  #     #  #  #  # ~~~~~~~~~");
    printf("\n~~~~~~~~~ #     #  #     #  #     #  #  #  # ~~~~~~~~~");
    printf("\n~~~~~~~~~ ######    #####    #####   #  #  # ~~~~~~~~~");
    printf("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    printf("\nThe bomb has blown up.\n");
    printf("The TA team has been notified. Just kidding :p\n");
    printf("Never mind. Everyone fails at the beginning.\n");

    exit(8);
}

/* Have you defused the bomb? */
void phase_defused(void)
{

    if (num_input_strings == 2) /* user has just defused phase 2 */
	    printf ("Congratulations! You've defused the practice bomb!\n");

}