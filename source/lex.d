import scanner, token, tree, std.stdio, std.regex;

class Lexer{

    Scanner scan;
    Token[] tokenList;


    this(Scanner s)
    {
        scan = s;
    }

    public Token[] getTokens()
    {
        return tokenList;
    }

    int charType(char c)
    {
        if (c >= '0' && c <= '9')
            return 0;
        else if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')
            return 1;
        else if (c == ' ' || c == '\t' || c == '\n')
            return 2;
        else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '&' || c == '|' || c == '=' || c == '!' || c == '>' || c == '<')
            return 3;
        else
            return -1;
    }


    private Token parseString()
    {
        char c;
        Token tK;
        string text = "";
        Op[string] keywords;
        keywords["for"] = Op.FOR;
        keywords["if"] = Op.IF;
        keywords["int"] = Op.INT;
        keywords["void"] = Op.VOID;
        auto number = ctRegex!(`^((\d)|(0[xob]{1})){1}(\d|[a-f]|[A-F])*$`);
        auto identifier = ctRegex!(`^([A-z]|_){1}(\d|\w)*$`);

        Token funcOrVar(string data)
        {
            char c;
            Token toReturn;

            do
            {
                scan.moveNext;
                c = scan.readChar;

                if(c == ' ' || c == '\t')
                    continue;

                if(charType(c) == 3 || c == ';' || c == ')')
                    toReturn = createToken(Op.VAR, data);
                else if(c == '(')
                    toReturn = createToken(Op.FUNC, data);
                else
                    toReturn = createToken(Op.ERROR, scan.getInfo ~ " Invalid identifier.");

            }while(!toReturn.t);
            scan.movePrev;
            return toReturn;
        }

        do
        {
            c = scan.readChar;

            Op* t = (text~c in keywords);
            if (t != null)
                return createToken(*t, null);

            if (charType(c) == 0 || charType(c) == 1)
                text ~= c;
            else
            {
                scan.movePrev;
                if(match(text, number))
                    return createToken(Op.NUMBER, text);
                if(match(text, identifier))
                    return funcOrVar(text);

                return createToken(Op.ERROR, scan.getInfo ~ "\tInvalid token.");
            }

        }while(scan.moveNext);
        return createToken(Op.ERROR, scan.getInfo ~ "\t reached EOF");
    }

    public void lex()
    {
        bool endOfFile = false;

        while (!endOfFile)
        {
            switch(scan.readChar)
            {
                //Single char Ops
                case ' ':
                case '\t':
                case '\n':
                    break;
                case '{':
                    tokenList ~= createToken(Op.OPEN_BRACE, null);
                    break;
                case '}':
                    tokenList ~= createToken(Op.CLOSE_BRACE, null);
                    break;
                case '(':
                    tokenList ~= createToken(Op.OPEN_BRACKET, null);
                    break;
                case ')':
                    tokenList ~= createToken(Op.CLOSE_BRACKET, null);
                    break;
                case ';':
                    tokenList ~= createToken(Op.SEMICOLON, null);
                    break;

                //Multi char Ops
                case '<':
                    scan.moveNext;
                    if(scan.readChar == '=')
                    {
                        tokenList ~= createToken(Op.LTE, null);
                    }else{
                        tokenList ~= createToken(Op.LT, null);
                        scan.movePrev;
                    }
                    break;
                case '>':
                    scan.moveNext;
                    if(scan.readChar == '=')
                    {
                        tokenList ~= createToken(Op.GTE, null);
                    }else{
                        tokenList ~= createToken(Op.GT, null);
                        scan.movePrev;
                    }
                    break;
                case '=':
                    scan.moveNext;
                    if(scan.readChar == '=')
                    {
                        tokenList ~= createToken(Op.EQUAL, null);
                    }else{
                        tokenList ~= createToken(Op.ASSIGN, null);
                        scan.movePrev;
                    }
                    break;
                case '!':
                    scan.moveNext;
                    if(scan.readChar == '=')
                    {
                        tokenList ~= createToken(Op.NOT_EQUAL, null);
                    }else{
                        tokenList ~= createToken(Op.NOT, null);
                        scan.movePrev;
                    }
                    break;
                case '+':
                    scan.moveNext;
                    if(scan.readChar == '+'){
                        tokenList ~= createToken(Op.INC, null);
                    }else if(scan.readChar == '='){
                        tokenList ~= createToken(Op.AINC, null);
                    }else{
                        tokenList ~= createToken(Op.PLUS, null);
                        scan.movePrev;
                    }
                    break;
                case '-':
                    scan.moveNext;
                    if(scan.readChar == '-'){
                        tokenList ~= createToken(Op.DEC, null);
                    }else if(scan.readChar == '-'){
                        tokenList ~= createToken(Op.ADEC, null);
                    }else{
                        tokenList ~= createToken(Op.MINUS, null);
                        scan.movePrev;
                    }
                    break;
                case '*':
                    tokenList ~= createToken(Op.MULTIPLY, null);
                    break;
                case '/':
                    tokenList ~= createToken(Op.DIVIDE, null);
                    break;
                default:
                    tokenList ~= parseString;
                    break;

            }
            endOfFile = !scan.moveNext;
        }

    }

    public void createSyntaxTree()
    {
        foreach(Token t ; tokenList)
            printToken(t);
    }

}
