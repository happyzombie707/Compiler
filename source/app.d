import std.stdio, std.range, std.file, std.uni, std.format;
import core.stdc.stdio;
import lex, token, scanner, equation;

//entry
void main(string[] args)
{
    //open and read file, no error checking atm
	string fileName = args[1];
	string file;
	File f = File(fileName, "r");

	foreach (char[] line; f.byLine())
		file ~= line~"\n";

    //create scanner using contents of file
	Scanner s = new Scanner(file);
    write(s.getFile);
    //analyse file using scanner
	Lexer l = new Lexer(s);
	l.lex;

    foreach(Token t ; l.getTokens)
        writeln(tokenString(t));

    writeln;


}
