import std.stdio, std.format;

/**
    Token struct - holds op, line column and extra data
*/
struct Token
{
        Op t;
        int ln, col;
        string data;
}

/*return string representation of a token*/
string tokenString(Token t, bool info = false)
{
    return info ? format("%d:%d",t.ln,t.col):"" ~ format("%s%s", t.t, (t.data)? " ("~t.data~")" : "");
}

/*return token struct with given parameters*/
Token createToken(Op type, string tData=null, int line = 0, int column = 0 )
{
    Token t = { t:type, ln:line, col:column, data:tData };
    return t;
}

/*whether token is an assignment*/
bool assignment(Op o)
{
    return (o >= Op.VOID && o <= Op.DEC);
}

/*Whether a token is an operation*/
bool isOp(Op o)
{
    return (o >= Op.PLUS && o <= Op.NOT_EQUAL);
}

/*List of possible tokens (Op is a bad name)*/
enum Op
{
    NULL,
    SEMICOLON,  //0
    //formatting
    OPEN_BRACE,
    CLOSE_BRACE,
    OPEN_BRACKET,
    CLOSE_BRACKET,
    //op
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
    //declaration
    VOID,
    INT,
    VAR,
    FUNC,
    //assignment
    ASSIGN,
    INC,
    DEC,
    AINC,
    ADEC,
    //keywords
    IF,
    FOR,
    //special things
    EXP,
    ADDR,
    NUMBER = 254,
    ERROR = 255,

}
