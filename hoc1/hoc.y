/* hoc v1 CH8 */

%{

#define YYSTYPE double /* data type of yacc stack */
/* adhere to C99 */
#include <stdio.h>
#include <ctype.h>

int yylex();
void yyerror(char *s);
void warning(char *s, char *t);

%}

%token NUMBER
%left '+' '-' /* left associative, same precedence */
%left '*' '/' /* left assoc., higher precedence */
%left UNARYMINUS
%left UNARYPLUS

%%
list:	 /* nothing */
    | list '\n'
    | list expr '\n'	{ printf("\t%.8g\n", $2); }
    ;
expr:	NUMBER		{ $$ = $1; }
    | '-' expr 		%prec UNARYMINUS { $$ = -$2; }
    | '+' expr 		%prec UNARYPLUS { $$ = +$2; }
    | expr '+' expr	{ $$ = $1 + $3; }
    | expr '-' expr	{ $$ = $1 - $3; }
    | expr '*' expr	{ $$ = $1 * $3; }
    | expr '/' expr	{ $$ = $1 / $3; }
    | '(' expr ')'	{ $$ = $2; }
    ;
%%
	/* end of grammar */

/* (Optional) C statements may reside here */

char *progname;		/* for error messages */
int  lineno = 1;

int yylex()
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* number */
		ungetc(c, stdin);
		/* reminder to double check work as I wrote a
		1 here instead of l and spent 30 mins chasing it
		down */
		scanf("%lf", &yylval);
		return NUMBER;
	}
	if ( c == '\n')
		lineno++;
	return c;
}

void yyerror(char *s) 
{
	warning(s, (char *) 0);
}

void warning(char *s, char *t)
{
	fprintf(stderr, "%s: %s", progname, s);
	if (t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " near line %d\n", lineno);
}

int main(int argc, char* argv[])	/* hoc1 */
{
	progname = argv[0];
	yyparse();
}
