#ifndef TESTS_H
#define TESTS_H

typedef struct IntDynamicArray
{
	int* values;
	unsigned long long length;
} IntDynamicArray;

//Gets a string ptr created from D
extern char* getStringFromD();
//Creates a Test class instance
extern void* createTest();
//Prints wether the dynamic cast succeeded or not
extern void checkDynamicCast(void* _TestInstance);
//Returns a float
extern float getFloatFromD();
//Creates a dynamic array, sum all its values, return it
extern int getDynamicArraySum();
//Returns a struct with ptr and length to a dynamically allocated array on D code
extern IntDynamicArray intDynamicArrayFromD();



#endif