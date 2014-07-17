/*

	Tomato Firmware
	Copyright (C) 2006-2009 Jonathan Zarate

*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdarg.h>

#include <bcmnvram.h>
#include "shutils.h"
#include "shared.h"

const char *find_word(const char *buffer, const char *word)
{
	const char *p, *q;
	int n;

	n = strlen(word);
	p = buffer;
	while ((p = strstr(p, word)) != NULL) {
		if ((p == buffer) || (*(p - 1) == ' ') || (*(p - 1) == ',')) {
			q = p + n;
			if ((*q == ' ') || (*q == ',') || (*q == 0)) {
				return p;
			}
		}
		++p;
	}
	return NULL;
}

/*
static void add_word(char *buffer, const char *word, int max)
{
	if ((*buffer != 0) && (buffer[strlen(buffer) - 1] != ' '))
		strlcat(buffer, " ", max);
	strlcat(buffer, word, max);
}
*/

int remove_word(char *buffer, const char *word)
{
	char *p;
	char *q;

	if ((p = strstr(buffer, word)) == NULL) return 0;
	q = p;
	p += strlen(word);
	while (*p == ' ') ++p;
	while ((q > buffer) && (*(q - 1) == ' ')) --q;
	if (*q != 0) *q++ = ' ';
	strcpy(q, p);

	return 1;
}

/* Hyzoom bwq518 */
char * trimstr(char *str)
{
	int i,j, len, count;

	if (str == NULL) return NULL;
	len = strlen(str);
	if (len == 0) return str;

	for (i = 0; i < len; i ++)
	{
		if ((str[i] != ' ') && (str[i] != '\t'))  break;
	}
	if (i == (len - 1))
	{
		*str = '\0';
		return str;
	}

	for ( j = len - 1; j >= 0 ; j --)
	{
		if ((str[j] != ' ') && (str[j] != '\t')) break;
	}
	if ( (j == 0) || (j <= i))
	{
		*str = '\0';
		return str;
	}
	count = j - i + 1 ;
	for ( j = 0; j < count; j ++)
	{
		*(str + j) = *(str + j + i);
	}
	*(str + count) = '\0';
	return str;
}

char * splitpath( char *str, char *pathname, char *filename)
{
	char *rear;
	int i, len;

	len = strlen(str);
	if (len == 0)
	{
		pathname[0] = '\0';
		filename[0] = '\0';
		return pathname;
	}

	i = 0;
	rear = str + len - 1;
	while(*rear != '/')
	{
		rear--;
		i ++;
		if (i >= len) break;
	}
	if (i == len)
	{
		pathname[0] = '\0';
		strcpy(filename, str);
	}
	else
	{
		strncpy(pathname, str, len - i);
		pathname[len - i ] = '\0';
		strncpy(filename, str + len - i, i);
		filename[i] = '\0';
	}

	return pathname;
}

int is_port(char *str)
{
	int i;

	for(i=0; str[i]!='\0';i++)
	{
		if ((isdigit(str[i])==0) && (str[i] != ':') && (str[i] != '-') && (str[i] != ' '))
			return 0;
	}
	return 1;
}

char *filter_space(char *str)
{
	int i = 0,j = 0;

	while(str[i])
	{
		if(str[i]!=' ')
			str[j++]=str[i];
		i++;
	}
	str[j]='\0';
	return str;
}

char* format_port(char *str)
{
	int i;

	filter_space(str);
	for (i = 0; i < strlen(str); i ++)
	{
		if ( str[i] == '-') str[i] = ':';
	}
	return str;
}

int splitport(char *in_ports, char out_port[MAX_PORTS][PORT_SIZE])
{
	int i, j = 0, k = 0, len;

	trimstr(in_ports);
	if ((len=strlen(in_ports)) == 0) return 0;
	for (i = 0; i < len; i ++)
	{
		if ((in_ports[i] == ',') || (in_ports[i] == ' '))
		{
			out_port[j][k] = '\0';
			trimstr(out_port[j]);

			if ((strlen (out_port[j]) > 0)  && (is_port(out_port[j]) == 1)) 
			{
				format_port(out_port[j]);
				j ++;
			}
			if (j >= MAX_PORTS) break;
			k = 0;
		}
		else
		{
			//printf("%c\n",in_ports[i]);
			out_port[j][k] = in_ports[i];
			if (k < PORT_SIZE) k ++;
		}
	}
	out_port[j][k] = '\0';
	trimstr(out_port[j]);
	if (strlen (out_port[j]) > 0)
	{
		format_port(out_port[j]);
		j ++;
	}
	return j;

}

/*  Check a string whether all of number or not
    return 1: all number
0: NOT all numer
*/
int is_number(char *a)
{
	int len = strlen(a);
	int i,j =0;
	if(len == 0) return 0; //NULL string
	for(i=0;i<len;i++)
	{
		if(a[i]<=57&&a[i]>=48)
		{j++;}
	}
	if (j==len) return 1;
	else return 0;
}
