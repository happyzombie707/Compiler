import std.range, std.format, std.algorithm, token;

//scanner for token lists, same as below just tokens instead of chars
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

//string scanner
class Scanner
{

    string file;                //file contents
    int[] lineLen;              //keeps track of the length of past lines
    int line, column, strPtr;   //line, column and current char in string
    ulong length;               //length
    bool lastCNewline;          //whether last char was a newline


    //reset if need to be reused
    public void reset()
    {
        lineLen = [];
        line = 1; column = 1; strPtr = 0;
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
        reset();
    }


    public char readChar()
    {
        return file[clamp(strPtr, 0, file.length-1)];
    }

    public bool moveNext()
    {
        //return false if moving strPtr out of bounds
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

        //if current char is newline set last char newline flag to true
        lastCNewline = (readChar == '\n');

        //return true on success
        return true;
    }


    public bool movePrev()
    {
        //if pointer already at start return false
        if (strPtr == 0)
            return false;

        //decrease current char and column value
        strPtr--; column--;

        //if newline
        if (readChar == '\n')
        {   //new column length = length of previous line
            column = lineLen[lineLen.length -1];
            lineLen.popBack();//remove current line length from stack
            line--;
        }

        //success!
        return true;
    }
}
