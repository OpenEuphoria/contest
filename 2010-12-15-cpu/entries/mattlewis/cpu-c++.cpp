#include <vector>
#include <iostream>
#include <fstream>
#include <string.h>
#include <stdlib.h>

class Op {
public:
	Op(){}
	virtual void exec() = 0;
};

class Halt : public Op {
public:
	Halt():Op(){};
	virtual void exec(){ exit( 0 ); }
};

class CPU {
public:
	CPU( const char *file_name ) : _pc(0){ load( file_name ); run(); }
	
	
private:
	std::vector<Op*> _code;
	void run();
	void load( const char *file_name );
	int _pc;
	int _reg[10];
	int _ram[1000];
};


class RegisterLiteral : public Op {
public:
	RegisterLiteral( int *reg, int literal );
		
protected:
	int _literal;
	int *_r1;
};

RegisterLiteral::RegisterLiteral( int *reg, int literal ):
	Op(), _r1( reg ), _literal( literal ){
	
}

class RegisterRegister : public Op {
public:
	RegisterRegister( int *reg1, int *reg2 );
	
protected:
	int *_r1;
	int *_r2;
};

RegisterRegister::RegisterRegister( int *reg1, int *reg2 ):
	Op(), _r1( reg1 ), _r2( reg2 ){
		
}

class AssignLiteral : public RegisterLiteral {
public:
	AssignLiteral( int *reg, int literal ): RegisterLiteral( reg, literal ){}
	virtual void exec(){ *_r1 = _literal; }
};

class AddLiteral : public RegisterLiteral {
public:
	AddLiteral( int *reg, int literal ):RegisterLiteral( reg, literal){}
	virtual void exec(){ *_r1 += _literal; }
};

class MultiplyLiteral : public RegisterLiteral {
public:
	MultiplyLiteral( int *reg, int literal ):RegisterLiteral( reg, literal ){}
	virtual void exec(){ *_r1 *= _literal; }
};

class AssignRegister : public RegisterRegister {
public:
	AssignRegister( int *reg1, int *reg2 ):RegisterRegister( reg1, reg2 ){}
	virtual void exec(){ *_r1 = *_r2; }
};

class AddRegister : public RegisterRegister {
public:
	AddRegister( int *reg1, int *reg2 ) : RegisterRegister( reg1, reg2 ){}
	virtual void exec();
};
void AddRegister::exec(){ 
#ifdef DEBUG
	std::cout << "Add Register " << *_r1 << " + " << *_r2 << " = " << (*_r1 + *_r2) << std::endl;
#endif
	*_r1 += *_r2; 
}
class MultiplyRegister : public RegisterRegister {
public:
	MultiplyRegister( int *reg1, int *reg2 ) : RegisterRegister( reg1, reg2 ) {}
	virtual void exec(){ *_r1 *= *_r2; }
};

class RamOp : public RegisterRegister {
public:
	RamOp( int *reg1, int *reg2, int *ram ) : RegisterRegister( reg1, reg2 ), _ram( ram ){}
protected:
	int *_ram;
};

class AssignFromRam : public RamOp {
public:
	AssignFromRam( int *reg1, int *reg2, int *ram ) : RamOp( reg1, reg2, ram ){}
	virtual void exec(){ *_r1 = _ram[*_r2]; }
};

class AssignToRam : public RamOp {
public:
	AssignToRam( int *reg1, int *reg2, int *ram ) : RamOp( reg1, reg2, ram ){}
	virtual void exec(){ _ram[*_r2] = *_r1; }
};


class Print : public Op {
public:
	Print( int *reg1 ) : Op(), _r1( reg1 ){}
protected:
	int *_r1;
};

class PrintLine : public Print {
public:
	PrintLine( int *reg1 ) : Print( reg1 ){}
	virtual void exec(){ std::cout << *_r1 << std::endl; }
};

class PrintSpace : public Print {
public:
	PrintSpace( int *reg1 ) : Print( reg1 ){}
	virtual void exec(){ std::cout << *_r1 << " "; }
};

class Jump : public RegisterRegister {
public:
	Jump( int *reg1, int *reg2, int *pc) : RegisterRegister( reg1, reg2 ), _pc( pc ) {}
	virtual void exec();
private:
	int *_pc;
};

void Jump::exec(){
	if( *_r2 ){
#ifdef DEBUG
	std::cout << "Jump to instruction " << *_r1 << std::endl;
#endif
		*_pc = *_r1 - 1;
	}
}

void CPU::load( const char* file_name ){
	std::ifstream in( file_name );
	char c;
	char linebuff[8192];
	in.get( c );
	while( in.good() ){
		switch( c ){
			case '0':
				_code.push_back( new Jump( _reg + in.get() - '0', _reg + in.get() - '0', &_pc ) );
				break;
			case '1':
				_code.push_back( new Halt() );
				break;
			case '2':
				_code.push_back( new AssignLiteral( _reg + in.get() - '0', in.get() - '0' ) );
				break;
			case '3':
				_code.push_back( new AddLiteral( _reg + in.get() - '0', in.get() - '0' ) );
				break;
			case '4':
				_code.push_back( new MultiplyLiteral( _reg + in.get() - '0', in.get() - '0' ) );
				break;
			case '5':
				_code.push_back( new AssignRegister( _reg + in.get() - '0', _reg + in.get() - '0' ) );
				break;
			case '6':
				_code.push_back( new AddRegister( _reg + in.get() - '0', _reg + in.get() - '0' ) );
				break;
			case '7':
				_code.push_back(new  MultiplyRegister( _reg + in.get() - '0', _reg + in.get() - '0' ) );
				break;
			case '8':
				_code.push_back( new AssignFromRam( _reg + in.get() - '0', _reg + in.get() - '0', _ram ) );
				break;
			case '9':
				_code.push_back( new AssignToRam( _reg + in.get() - '0', _reg + in.get() - '0', _ram ) );
				break;
			case '?':
				c = in.get();
				if( c == '?' ){
					_code.push_back( new PrintSpace( _reg + in.get()  - '0') );
				}
				else{
					_code.push_back( new PrintLine( _reg + c  - '0') );
				}
		}
		in.getline( linebuff, 8191 ); // read to the end of the line...
		in.get( c );
	}
	_code.push_back( new Halt() );
}

void CPU::run(){
	memset( _ram, 0, sizeof( int ) * 1000 );
	memset( _reg, 0, sizeof( int ) * 10 );
	_ram[0] = -1;
	for( _pc = 0; ; ++_pc ){
#ifdef DEBUG
		std::cout << "pc[" << _pc << "]";
		for( int i = 0; i < 10; ++i ){
			std::cout << " " << _reg[i];
		}
		std::cout << std::endl;
#endif
		_code[_pc]->exec();
	}
}

int main( int argc, const char* argv[] ){
	CPU cpu( argv[1] );
	return 0;
}