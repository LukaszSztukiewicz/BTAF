/*
==============================================
                Sample main file
    replace it with your own program for testing

Input:
 any array of chars (max 100)
Output:
 the same array of chars

==============================================
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char *argv[]) {
  char *ptr = malloc(100 * sizeof(char));
  scanf("%s", ptr);
  printf("%s", ptr);
  return 0;
}