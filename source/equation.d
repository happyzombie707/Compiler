import scanner, token;
import std.conv, std.stdio, std.array, std.regex, std.algorithm;
import core.memory;

Token t;


int[Op] opLength;
int[Op] opPrecedence;
void init()
{
    opLength[Op.PLUS] = 2;
    opLength[Op.MINUS] = 2;
    opLength[Op.MULTIPLY] = 2;
    opLength[Op.DIVIDE] = 2;
    opLength[Op.NUMBER] = 0;

    opPrecedence[Op.DIVIDE] = 2;
    opPrecedence[Op.MULTIPLY] = 2;
    opPrecedence[Op.PLUS] = 1;
    opPrecedence[Op.MINUS] = 1;
    opPrecedence[Op.NUMBER] = 0;
    opPrecedence[Op.EXP] = 4;
}

class EquationTree{
    struct Node{
        Op o;
        Node* parent;
        Node*[] children;
        string data;
    }

    void addNode(Node* node, string data = null)
    {
        Node tN = { parent:node, data:data };
        Node* np = cast(Node*)GC.malloc(Node.sizeof);
        node.children ~= np;
        *np = tN;

        //if(!data)
            //current = np;
    }


}

int charValue(char c)
{
    if(c > 47 && c < 58)
        return cast(int)(c - '0');
    else if(c > 64 && c < 91)
        return cast(int)(c - 55);
    else if(c > 96 && c < 123)
        return cast(int)(c - 87);

    return 0;
}

int parseValue(string val, int base)
{
    int total = 0;
    int multiplier = 1;
    int dbg = 1;

    for(int i = cast(int)val.length-1; i >= 0; i--)
    {
        char c = val[i];
        writefln("Column %d: multiplying %c(%d) by %d", dbg, c, charValue(c), multiplier);
        total += charValue(c) * multiplier;
        multiplier *= base; dbg++;
    }
    writefln("%s in base %d = %d", val, base, total);
    return total;
}

int parseNum(string toParse)
{
    int base;
    string value;

    if (toParse.length > 2)
    {
        if(toParse[1] == 'x')
            base = 16;
        else if(toParse[1] == 'o')
            base = 8;
        else if(toParse[1] == 'b')
            base = 2;
        else
            base = 10;

        value = toParse[2..toParse.length].replace(" ", "");
    }else{base = 10;}

    return parseValue(value, base);
}

public int getPrecedence(Token t)
{
    return opPrecedence[t.t];
}

public bool isExpression(Token t)
{
    return (t.t == Op.MULTIPLY) || (t.t == Op.DIVIDE);
}

public bool leftAssoc(Token t)
{
    return (t.t == Op.PLUS) || (t.t == Op.MINUS);

}

public bool isOperator(Token t)
{
    return isExpression(t) || leftAssoc(t);
}

public bool isNumber(Token t)
{
    return (t.t == Op.NUMBER);
}


class Equation
{

    string[] sumList;
    private Token[][] tokenList;
    TokenScanner scan;

    public Token[] fillJumps()
    {
        Token t;
        Token[] tL;
        int d = 0;
        int nearestSub = -1;
        do
        {
            tL = tokenList[d];
            for(int i = 0; i < tL.length; i++)
            {
                t = tL[i];
                if (t.t == Op.EXP)
                {
                    tL = tL[0..i] ~ tokenList[0] ~ tL[i+1..$];
                    tokenList.popFront;
                    d--;
                }

            }
            tokenList[d] = tL;
            d++;
        }while(tokenList[].length > 1);
        return tokenList[0];
    }

    public Token[] createRPN(Token[] input)
    {

        Token t;
        //Token[] input = tokenList[0];

        scan = new TokenScanner(input);

        Token[] outputStack;
        Token[] operatorStack;

        do
        {
            t = scan.readToken;

            if(isNumber(t))
            {
                outputStack ~= t;
            }
            else
            {

                //if new less than top or top same but left assoc
                if(operatorStack.length <= 0)
                {
                    operatorStack ~= t;
                }
                else
                {
                    //writeln("-----\n"~newOp);
                    //writeln(oldOp~"\n-----");
                    while(operatorStack.length > 0){
                        Token oldT = operatorStack[$-1];

                        if(getPrecedence(t) < getPrecedence(oldT))
                        {
                            //writeln("new < old, popping");
                            outputStack ~= oldT;
                            operatorStack.popBack;
                            continue;
                        }else if(getPrecedence(t) == getPrecedence(oldT) && leftAssoc(t))
                        {
                            //writeln("new = old but rA, popping");
                            outputStack ~= oldT;
                            operatorStack.popBack;
                            continue;
                        }else{
                            break;
                        }
                    }
                    operatorStack ~= t;
                }
            }

        //writeln("AFTER "~c);
        }while(scan.moveNext);
        while(operatorStack.length > 0)
        {
            outputStack ~= operatorStack[$-1];
            operatorStack.popBack;
        }

        return outputStack;//outputStack.join(" ");
    }


    /*
    TODO
    get the createrpn function to read from the processed list of Tokens
    returning the processed function to the array

    add link swapping, so when the parser sees an expression tag it knows to
    (hopefully) plug in the already processed equation at the top of the queue,
    pop old one when inserted

    verify it's all good

    look into creating a variable table and a function table
    create AST
    */

    public void parse()
    {
        //writef("\n%d: ", depth);
        Token t;
        Token[] text;

        do
        {
            t = scan.readToken;
            switch(t.t)
            {
                case Op.OPEN_BRACKET:
                    scan.moveNext;
                    text ~= createToken(Op.EXP);
                    //depth++;
                    parse();
                    break;
                case Op.CLOSE_BRACKET:
                    //if(depth == 0)
                        //write("syntax error.");
                    tokenList ~= text;
                    return;

                case Op.PLUS: goto default;
                case Op.MINUS: goto default;
                case Op.MULTIPLY: goto default;
                case Op.DIVIDE: goto default;
                default:
                    text ~= t;
                    break;
            }
        }while(scan.moveNext);
        tokenList ~= text;
    }

    public void rpn()
    {
        for(int i = 0; i < tokenList.length; i++)
        {
            tokenList[i] = createRPN(tokenList[i]);
        }

    }

    public void fill()
    {
        foreach(Token t ; fillJumps)
        {
            printString(t);
        }
    }

    public this(Token[] tokens)
    {
        //tokenList = tokens;
        init();
        scan = new TokenScanner(tokens);
    }
}
