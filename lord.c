#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

// prints light if color (hex) passed is light, else dark
// usage: lord hexcolorcode


/*
 * print error message and exit
 * */
void error(char* msg){
	printf("%s\n", msg);
	exit(1);
}

/*
 * checks if passed hexcolorcode is valid or not (0 = invalid, 1 = valid)
 * */
int validatehex(char* hex){
	if(strlen(hex) != 6) // hex color code should be 6 digits
		return 0;
	for(int i = 0; i < 6; i++){ // check if 0-9 or a-f or A-F or not
		if(hex[i] >= '0' && hex[i] <= '9') continue;
		if(hex[i] >= 'a' && hex[i] <= 'f') continue;
		if(hex[i] >= 'A' && hex[i] <= 'F') continue;
		return 0;
	}
	return 1;
}


/*
 * convert arbitrary length string to lowercase
 * */
void lower(char* s){
	int l = strlen(s);
	for(int i = 0; i < l; i++){
		s[i] = tolower(s[i]);
	}
}

/*
 * convert a single hex character to its integer decimal representation
 * */
int hexchartoint(char c){
	c = tolower(c);
	if(c >= '0' && c <= '9') return c - 48;
	if(c >= 'a' && c <= 'f') return c - 'a' + 10;
	return -1;
}

/*
 * efficient integer exponentiation using binary representation
 * */
int intpow(int base, int exp){
	int rv = 1;
	while(exp > 0){
		if(exp & 1) rv *= base;
		exp >>= 1;
		base *= base;
	}
	return rv;
}

/*
 * convert arbitrary length hexadecimal string to integer decimal representation
 * */
int hextoint(char* hex){
	int len = strlen(hex);
	int rv = 0;
	for(int i = len-1; i >= 0; i--){
		int val = hexchartoint(hex[i]);	// get value of current character
		rv += val * intpow(16, len-1-i); // base conversion
	}
	return rv;
}
int main(int argc, char** argv) {
	char *color = calloc(8, sizeof(char)); // allocate memory for 6/7 digit hex
	if( color == NULL) error("memory allocation error");
	if(argc > 1) {	// if color passed as args, copy it from args to color
		if (strlen(argv[1]) > 7) error("Invalid hex code"); // if > 6 digits + #
		strcpy(color, argv[1]); // copy hex to color
	}
	else {
		printf("enter hex color code: "); // if not passed as arg, input
		scanf("%s", color);
	}

	/*
	 * Remove the # from begining if it exists
	 * */
	if (color[0]=='#') {
		char* c2 = calloc(7, sizeof(char));
		if (c2 == NULL) error("memory allocation error");
		strncpy(c2, color+1, 6);
		free(color);
		color = c2;
	}

	lower(color); // convert hex to lowercase
	if (! validatehex(color)) error("Invalid hex code"); // if hexcode not valid
	int icolor = hextoint(color); // get int representation of 16bit hex
	free(color);	// the string is no longer needed
	int r = (icolor >> 16) & 0xff;	// get red value (0-255)
	int g = (icolor >>  8) & 0xff;	// get green value (0-255)
	int b = (icolor >>  0) & 0xff;	// get blue value (0-255)
	float luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; // per ITU-R BT.709
	printf("%s\n" , (luma < 128 ? "dark" : "light")); // luma from 0 to 255
	return 0;
}
