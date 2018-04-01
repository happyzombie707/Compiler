import token, scanner;

/*
work in progress, doesn't really do anything atm
*/

//struct for tree nodes
struct Node
{
    Op t;
    Node[] children;
    Node[] parents;
    string data;
}

//class for tree
class Tree
{
    Token[] tokenList;
    TokenScanner scan;

    //needs work tbh
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
useful fail
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
