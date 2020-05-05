/* hoc v2 */

%{

double mem[26]; /* memory for variables 'a' .. 'z' */

#include <stdio.h>
#include <ctype.h>
#include <signal.h>
#include <setjmp.h>

int yylex();
void yyerror(char *s);
void warning(char *s, char *t);
void execerror(char *s, char *t);
void fpecatch();
double prev;

jmp_buf begin;

%}

%union { /* stack type */
	double val;	/* actual value */
	int index;	/* index into mem[] */
}
%token <val>	NUMBER
%token <index>	VAR
%type  <val> 	expr
%right '='
%left '+' '-'
%left '*' '/'
%left UNARYMINUS
%%

list:	 /* nothing */
    | list '\n'
    | list '?'		{ printf("PREV: \t%.8g\n", mem['p']); }
    | list expr '\n'	{ printf("\t%.8g\n", $2); }
    | list error '\n'	{ yyerrok; }
    ;
expr:	NUMBER		
    | VAR		{ $$ = mem[$1]; }
    | VAR '=' expr 	{ $$ = mem[$1] = $3; }
    | expr '+' expr	{ $$ = $1 + $3; mem['p' - 'a'] = $1 + $3; }
    | expr '-' expr	{ $$ = $1 - $3; mem['p' - 'a'] = $1 - $3; }
    | expr '*' expr	{ $$ = $1 * $3; mem['p' - 'a'] = $1 * $3; }
    | expr '/' expr	{ 
	if ($3 == 0.0)
		execerror("division by zero", "");
	$$ = $1 / $3; mem['p' - 'a'] = $1 / $3; }
    | '(' expr ')'	{ $$ = $2; }
    | '-' expr 		%prec UNARYMINUS { $$ = -$2; }
    ;
%%
	/* end of grammar */

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
		scanf("%lf", &yylval.val);
		return NUMBER;
	}
	if (islower(c)) {
		yylval.index = c - 'a'; /* ASCII only */
		return VAR;
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

void execerror(char *s, char *t)
{
	warning(s, t);
	longjmp(begin, 0);
}

void fpecatch() /* catch floating point exceptions */
{
	execerror("floating point exception", (char *) 0);
}

int main(int argc, char* argv[])	/* hoc2 */
{
	void fpecatch();

	progname = argv[0];
	setjmp(begin);
	signal(SIGFPE, fpecatch);
	yyparse();
}
