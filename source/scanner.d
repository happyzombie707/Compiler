import std.range, std.format, std.algorithm, token;
//1 min 3.3

class TokenScanner
{
    Token[] token;
    int tPtr;

    public bool moveNext()
    {
        if (!(tPtr+1 >= token.length))
            tPtr++;
        else
            return false;
        return true;
    }

    public bool movePrev()
    {
        if (!(tPtr-1 <= 0))
            tPtr--;
        else
            return false;
        return true;
    }
    public Token readToken()
    {
        return token[tPtr];
    }

    public this(Token[] t, int s = 0)
    {
        token = t;
        tPtr = s;
    }
}

class Scanner
{

    string file;
    int[] lineLen;
    int line, column, strPtr;
    ulong length;
    bool lastCNewline;

    public string printLineStack()
    {
        string s;
        int ln = 1;
        foreach( int i; lineLen )
        {
            s ~= format("Line %d: %d\n", ln, i);
            ln++;
        }
        return s;
    }

    public void reset()
    {
        lineLen = [];
        line = 0; column = 0; strPtr = 0;
        length = file.length;
        lastCNewline = false;
    }

    public string getFile()
    {
        return file;
    }
    
    public int getLine()
    {
        return line;
    }

    public int getCol()
    {
        return column;
    }

    public string getInfo()
    {
        return format("%d:%d", line, column);
    }

    public this(string file)
    {
        this.file = file;
        length = file.length;
        line = 1; column = 1; strPtr = 0;
        lastCNewline = false;
    }

    public char readChar()
    {
        return file[clamp(strPtr, 0, file.length-1)];
    }

    public bool moveNext()
    {
        //if moving strPtr out of bounds
        if(strPtr >= file.length-1)
            return false;


        //if the last char was a newline character increment the line number and reset column
        if (lastCNewline)
        {
            lineLen ~= column;
            column = 0;
            line++;
        }

        column++; strPtr++;

        //if current char a newline set last char newline flag to true
        lastCNewline = (readChar == '\n');

        //return true on success
        return true;
    }

    public bool movePrev()
    {

        if (strPtr == 0)
            return false;

        strPtr--; column--;

        lastCNewline = (readChar == '\n');

        if (lastCNewline)
        {
            column = lineLen[lineLen.length -1];
            lineLen.popBack();
            line--;
        }


        return true;
    }

}
