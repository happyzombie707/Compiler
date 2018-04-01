import std.stdio, std.range, std.file, std.uni, std.format;
import core.stdc.stdio;
import lex, token, scanner, equation;


void main(string[] args)
{

	string fileName = args[1];
	string file;
	File f = File(fileName, "r");

	foreach (char[] line; f.byLine())
		file ~= line~"\n";

	//writeln(file ~ '\n');

    write("BEFORE: ");
	Scanner s = new Scanner(file);
    write(s.getFile);
	Lexer l = new Lexer(s);
	l.lex;

    l.createSyntaxTree;

    /*Equation e = new Equation(l.getTokens);
    e.parse;
    e.rpn;
    write("AFTER:  ");
    e.fill;*/

    writeln;


}
