/*
==============================================
                INI PARSER
Input formats:
 1. ./program PATH_TO_INI expression "section.key+section.key"
 2. ./program PATH_TO_INI section.key

 Structure of ini save:
    [section] -> [keyke]

Mode 1 - expr eval
Mode 2 - section.key - only one,


==============================================
*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Key
{
  char *key;
  char *value;
  struct Key *nextkey;
};

struct Section
{
  char *name;
  struct Key *keys;
  struct Section *nextsection;
};

// define parse function returning pointer to struct section
struct Section *parse_file(FILE *file)
{
  struct Section *first_section = malloc(sizeof(struct Section));
  first_section->name = NULL;
  first_section->keys = NULL;
  first_section->nextsection = NULL;
  char buffer[1024];
  while (fgets(buffer, 1024, file) != NULL)
  {
    if (buffer[0] == '[')
    {
      char *section_name = buffer;
      section_name = strtok(section_name, "]");
      struct Section *new_section = malloc(sizeof(struct Section));
      new_section->name = malloc(sizeof(char) * strlen(section_name));
      strcpy(new_section->name, section_name + 1);
      new_section->keys = NULL;
      new_section->nextsection = NULL;
      if (first_section->name == NULL)
      {
        first_section = new_section;
      }
      else
      {
        struct Section *i_section = first_section;
        while (i_section->nextsection != NULL)
        {
          i_section = i_section->nextsection;
        }
        i_section->nextsection = new_section;
      }
    }
    else if (buffer[0] == '\n')
    {
      continue;
    }
    else
    {
      char *key_value = buffer;
      char *key = strtok(key_value, "=");
      char *value = strtok(NULL, "\n");
      struct Key *new_key = malloc(sizeof(struct Key));
      new_key->key = NULL;
      new_key->value = NULL;
      new_key->nextkey = NULL;
      new_key->key = malloc(sizeof(char) * strlen(key));
      key[strlen(key) - 1] = '\0';
      strcpy(new_key->key, key);
      new_key->value = malloc(sizeof(char) * strlen(value));
      strcpy(new_key->value, value + 1);
      struct Section *i_section = first_section;
      while (i_section->nextsection != NULL)
      {
        i_section = i_section->nextsection;
      }
      if (i_section->keys == NULL)
      {
        i_section->keys = new_key;
      }
      else
      {
        struct Key *i_key = i_section->keys;
        while (i_key->nextkey != NULL)
        {
          i_key = i_key->nextkey;
        }
        i_key->nextkey = new_key;
      }
    }
  }
  return first_section;
}

char *argv_validation(char *argv) {}

char *read_value_from_section(struct Section *first_section, char *section,
                              char *key)
{

  struct Section *i_section = malloc(sizeof(struct Section));
  i_section = first_section;
  while (strcmp(i_section->name, section) != 0)
  {
    if (i_section->nextsection == NULL)
      return "Section not found";
    i_section = i_section->nextsection;
  }

  struct Key *i_key = malloc(sizeof(struct Key));
  i_key = i_section->keys;
  while (strcmp(i_key->key, key) != 0)
  {
    if (i_key->nextkey == NULL)
      return "Key not found";
    i_key = i_key->nextkey;
  }
  return i_key->value;
}

int main(int argc, char *argv[])
{
  char *path = argv[1];
  FILE *file = fopen(path, "r");
  if (file == NULL)
  {
    printf("File not found\n");
    return 1;
  }
  struct Section *first_section = parse_file(file);
  fclose(file);
  // Mode 1
  if (argv[2] == "expression")
  {
    char *expression = argv[3];
    char *validation_result = argv_validation(expression);
    if (validation_result == "int")
    {
      // to implement
    }
    else if (validation_result == "string")
    {
      // to implement
    }
    else if (validation_result == "invalid")
    {
      printf("Invalid arguments for expression: %s\n", expression);
      return 1;
    }
    else
    {
      printf("Unexpected return from argv_validation function: %s\n",
             validation_result);
      return 1;
    }
  }

  // Mode2
  else
  {
    char *desired_section = strtok(argv[2], ".");
    char *desired_key = strtok(NULL, ".");
    char *result =
        read_value_from_section(first_section, desired_section, desired_key);
    printf("%s", result);
  }

  return 0;
}