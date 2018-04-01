import std.stdio;

struct Token
{
        Op t;
        int ln, col;
        string data;
}

void printString(Token t)
{
    writef("%s ", (t.data)?t.data : cast(char)t.t~"");

}
void printToken(Token t)
{
    writef("%d:%d - %s", t.ln, t.col, t.t);
    if(t.data != null)
        writef(" > %s", t.data );
    writeln;
}

Token createToken(Op type, string tData=null, int line = 0, int column = 0 )
{
    Token t = { t:type, ln:line, col:column, data:tData };
    return t;
}

bool assignment(Op o)
{
    return (o >= Op.VOID && o <= Op.DEC);
}

bool isOp(Op o)
{
    return (o >= Op.PLUS && o <= Op.NOT_EQUAL);
}

enum Op
{
    SEMICOLON,
    OPEN_BRACE,
    CLOSE_BRACE,
    OPEN_BRACKET,
    CLOSE_BRACKET,
    PLUS,
    MINUS,
    DIVIDE,
    MULTIPLY,
    NOT,
    GT,
    LT,
    GTE,
    LTE,
    EQUAL,
    NOT_EQUAL,
    VOID,
    INT,
    VAR,
    FUNC,
    DECLARE,
    ASSIGN,
    INC,
    DEC,
    IF,
    FOR,
    EXP,
    NUMBER = 254,
    ERROR = 255,
    AINC,
    ADEC,

}
