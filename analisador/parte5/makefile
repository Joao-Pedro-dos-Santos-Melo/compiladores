simples: lexico.l sintatico.y utils.c tree.c
	@flex -o lexico.c lexico.l
	@bison -v -d sintatico.y -o sintatico.c
	# Remova utils.c e tree.c daqui. Eles já estão incluídos no sintatico.c
	@gcc lexico.c sintatico.c -o simples
limpa : ;
	@echo "limpando..."
	@rm lexico.c sintatico.c sintatico.h sintatico.output simples