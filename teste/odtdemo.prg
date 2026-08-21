PROCEDURE Main()
   LOCAL oDoc
   
   // 1. Inicializa o documento com o nome desejado
   oDoc := DocumentODT():New( "relatorio.odt" )
   
   // 2. Adiciona titulos (o numero indica o nivel, ex: 1 = Titulo Principal, 2 = Subtitulo)
   oDoc:AddHeading( "Relatório Gerencial do DBU", 1 )
   
   // 3. Adiciona os paragrafos do texto
   oDoc:AddParagraph( "Este documento foi gerado 100% nativamente em Harbour." )
   oDoc:AddParagraph( "Não é necessário nenhuma DLL ou dependência externa." )
   
   oDoc:AddHeading( "Testando um Subtítulo", 2 )
   oDoc:AddParagraph( "Você pode conectar isso com os seus bancos de dados e gerar relatórios completos facilmente." )
   
   // 4. Salva o arquivo final compactado no disco
   oDoc:Save()
   
   OutStd( "Documento ODT gerado com sucesso!" )
RETURN