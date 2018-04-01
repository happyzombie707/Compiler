import token, scanner;
/*
read int token
expect function or variable
    variable
        expect = or ;
            =
                evaluate up to ; as expression

    function
        need (
            can have {type, identifier} for 0 - n
        need )
        need {
            evaluate to } as code
            no nested functions
*/

struct Node
{
    Op t;
    Node[] children;
    Node[] parents;
    string data;
}

class Tree
{
    Token[] tokenList;
    TokenScanner scan;

    private Token[] assign(Token t)
    {

    }

    public void buildTree()
    {
        Token t;
        do
        {
            t = scan.readToken;
        }while(scan.moveNext);
    }

    public this(Token[] tokenList)
    {
        this.tokenList = tokenList;
        scan = new TokenScanner(tokenList);
    }
}
/*


struct BranchNode
{
    Op t;
    Node* parent;
    // n;
    //alias n this;
}

struct LeafNode
{
    BranchNode parent;
    string data;
}

class Tree
{
    Node root = {t:Op.ROOT};
    Node current;

    this()
    {
        current = root;
    }

    private bool addNode(Op tE)
    {
    //    current.children ~= {t:tE}
    //    current.children[current.children.length-1]
    }

    /*public bool addToken(Token toAdd)
    {
        switch(toAdd.t)
        {
            case Op.INT:

        }
        return false;
    }

}*/
