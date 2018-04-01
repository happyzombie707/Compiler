import scanner, token;
import std.conv, std.stdio, std.array, std.regex, std.algorithm;
import core.memory;

Token t;//?

//experiment
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

/*
    tree test with pointers
    may merge tree.d and this to make the AST, rename parser.d
*/
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

/*utility funcitons, might move*/
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

//need to move to token.d
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

/*
    equation class
    uses shunting yard algorithm to convert expressions to RPN
*/
class Equation
{
    //first evaluate brackets and separate them by depth leaving a placeholder  - parse
    //convert the separate expression to RPN                                    - convertRPN
    //collapse the list of expressions back into a single expression            - collapse

    //2d token list, stores tokens in rows, used a bit like a queue
    private Token[][] tokenQueue;
    TokenScanner scan;

    //return a single list with all the brackets merged
    public Token[] collapse()
    {

        Token t;        //current token
        Token[] tL;     //current row of tokens
        int d = 0;      //depth

        do//while there is more than 1 list of tokens in the stack
        {
            tL = tokenQueue[d]; //current list = queue at depth (starts at front)
            for(int i = 0; i < tL.length; i++)//for each token in the list
            {
                t = tL[i];
                //if token is expression placeholder
                if (t.t == Op.EXP)
                {   //pop front of queue and insert in current expression
                    tL = tL[0..i] ~ tokenQueue[0] ~ tL[i+1..$];
                    tokenQueue.popFront;
                    d--;
                }
            }
            //if expression were merged insert new expression into queue at new depth
            //if they weren't it just adds the same list back into the same location on the queue
            tokenQueue[d] = tL;
            d++;
        }while(tokenQueue[].length > 1);

        //return first element of the token queue (final expression)
        return tokenQueue[0];
    }

    //convert list of tokens to a list of RPN tokens
    public Token[] convertRPN(Token[] input)
    {

        Token t;    //holder

        scan = new TokenScanner(input); //scanner

        //stacks to hold outputs and operators to put on the output
        Token[] outputStack;
        Token[] operatorStack;

        do  //while tokens available
        {
            //read
            t = scan.readToken;

            //if token is a number put on output stack
            if(isNumber(t))
            {
                outputStack ~= t;
            }
            else
            {
                //push value on stack if empty
                if(operatorStack.length <= 0)
                {
                    operatorStack ~= t;
                }
                else//if not empty
                {
                    //while tokens in operator stack
                    while(operatorStack.length > 0)
                    {
                        Token oldT = operatorStack[$-1]; //get last token on stack

                        //if old token has a higher precedence
                        if(getPrecedence(t) < getPrecedence(oldT))
                        {
                            //put old token on output stack
                            outputStack ~= oldT;
                            operatorStack.popBack;
                            continue; //next loop
                        //if old token has equal precedence and is left associative
                        }else if(getPrecedence(t) == getPrecedence(oldT) && leftAssoc(t))
                        {
                            //as above
                            outputStack ~= oldT;
                            operatorStack.popBack;
                            continue;
                        }
                        //if neither of the above
                        break;
                    }//add to operator stack
                    operatorStack ~= t;
                }
            }

        }while(scan.moveNext);
        //when parsing the tokens is done, push any remaining operators to the output stack
        while(operatorStack.length > 0)
        {
            outputStack ~= operatorStack[$-1];
            operatorStack.popBack;
        }

        return outputStack;
    }

    /*split expressions based on brackets, leaves a placeholder token behind*/
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
                    tokenQueue ~= text;
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
        tokenQueue ~= text;
    }

    //workaround, need to change something
    public void rpn()
    {
        for(int i = 0; i < tokenQueue.length; i++)
        {
            tokenQueue[i] = convertRPN(tokenQueue[i]);
        }

    }
    //same
    public void fill()
    {
        foreach(Token t ; collapse)
        {
            writeln(tokenString(t));
        }
    }
    //constrictor
    public this(Token[] tokens)
    {
        //tokenQueue = tokens;
        init();
        scan = new TokenScanner(tokens);
    }
}
