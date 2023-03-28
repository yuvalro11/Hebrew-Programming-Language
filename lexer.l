%option noyywrap
%option c++
%option bison-bridge

%{
    #include <iostream>
    #include <fstream>

    std::string str;
%}

%x STRING RSTRING FSTRING COMMENT

/* test for hebrew character as they are 2 bytes in utf-8 encoding */
HEBREW  \xD7[\x90-\xAA]

LETTER  [a-zA-Z]|{HEBREW}
INT     [[:digit:]{-}0][[:digit:]]*
FLOAT   ({INT}|0)\.[[:digit:]]*
ID      {LETTER}({LETTER}|[[:digit:]])*

%%

 /* keywords */
אם                 {std::cout << "if ";}
אחרת               {std::cout << "else ";}
פונק                {std::cout << "func ";}
החזר                {std::cout << "return ";}
כאשר               {std::cout << "while ";}
עבור                {std::cout << "for ";}
בתוך                {std::cout << "in ";}
צא                 {std::cout << "break ";}
המשך               {std::cout << "continue ";}
אמת                {std::cout << "true ";}
שקר                {std::cout << "false ";}

 /* operators */
\+                 {std::cout << "plus ";}
\+=                {std::cout << "plseq ";}
\-                 {std::cout << "minus ";}
\-=                {std::cout << "mineq ";}
\/                 {std::cout << "divied ";}
\/=                {std::cout << "diveq ";}
\*                 {std::cout << "multiply ";}
\*=                {std::cout << "multeq ";}
\=                 {std::cout << "assign ";}

 /* comparison operators */
\=\=               {std::cout << "eq ";}
\>                 {std::cout << "gt ";}
\>\=               {std::cout << "ge ";}
\<                 {std::cout << "lt ";}
\<\=               {std::cout << "le ";}
!\=                {std::cout << "ne ";}
!                  {std::cout << "not ";}

 /*string parsing*/
\"                 {str = ""; BEGIN(STRING);}
פ\"                {str = ""; BEGIN(FSTRING);}
ר\"                {str = ""; BEGIN(RSTRING);}

(                  {std::cout << "( ";}
)                  {std::cout << ") ";}
[                  {std::cout << "[ ";}
]                  {std::cout << "] ";}


<FSTRING>{

    <STRING>{
        \\n  {str.append(yytext, 0, YYLeng() - 2); str.append("\n");}
        \\t  {str.append(yytext, 0, YYLeng() - 2); str.append("\t");}
        \\r  {str.append(yytext, 0, YYLeng() - 2); str.append("\r");}
        \\b  {str.append(yytext, 0, YYLeng() - 2); str.append("\b");}
        \\f  {str.append(yytext, 0, YYLeng() - 2); str.append("\f");}
	\\\" {str.append(yytext, 0, YYLeng() - 2); str.append("\"");}

        <RSTRING>{
            \"    {BEGIN(INITIAL); std::cout << str << " ";}
            \n    {std::cout << "error";}
	    \\    {str.append(yytext);}
            [^\\\n\"]+ {str.append(yytext);}
            <<EOF>> {std::cout << "error";}
        }
    }
}

"/*"               {BEGIN(COMMENT);}
"//".*             {}

<COMMENT>{
    "*/"           {BEGIN(INITIAL);}
    [^*]+          {}
    "*"[^/]        {}

}

{INT}              {std::cout << "integer ";}
{FLOAT}            {std::cout << "float ";}
{ID}               {std::cout << "identifier ";}
\n                 {std::cout << "newline\n";}

^([" "]{4})+       {std::cout << "indentation \"" <<  YYText() << "\" ";}
[[:space:]]        {}
.                  {std::cout << "unknown character - " << YYText();}

%%

int main( int argc, char *argv[] )
{
    ++argv, --argc;  /* skip over program name */

    if (argc == 0)
        return 1;

    std::ifstream ifile(argv[0]);

    if (!ifile.isopen())
	return 1;

    FlexLexer* lexer = new yyFlexLexer(&ifile);

    lexer->yylex();
    ifile.close();
    std::cout << "\n";

    return 0;
}
