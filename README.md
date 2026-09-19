# Harbour ODS/ODT/RTF/DOCX

Biblioteca em Harbour puro para geração de documentos e planilhas em formatos abertos e compatíveis com ferramentas de escritório, sem depender de Microsoft Office ou de DLLs externas.

Este repositório reúne classes para produzir arquivos em ODS, ODT e DOCX, com foco em portabilidade, simplicidade de uso e geração nativa em código Harbour.

## Visão geral

O projeto foi desenvolvido para criar documentos e planilhas diretamente a partir de código Harbour, empacotando os arquivos no padrão OpenDocument / Open XML e gerando ZIPs válidos com estrutura mínima necessária para abertura em LibreOffice, OpenOffice e outros aplicativos compatíveis.

As classes principais incluem:

- `WorkBookODS` — geração de planilhas no formato `.ods`
- `DocumentODT` — geração de documentos de texto no formato `.odt`
- `DocumentDOCX` — geração de documentos Word no formato `.docx`
- outros módulos auxiliares e utilitários para conversão e manipulação de formatos

## Funcionalidades

- 100% em Harbour puro
- Sem dependência de automação OLE
- Sem necessidade de LibreOffice ou Office instalados na máquina
- Geração de arquivos compatíveis com padrões abertos
- Suporte a múltiplas planilhas em ODS
- Suporte a blocos de texto, títulos e parágrafos em ODT
- Suporte a BBCode simples para formatação em ODT/DOCX (`[B]`, `[I]`, `[U]`, `[SIZE=12]`, `[PAGE]`)
- Criação de arquivos compactados em ZIP com estrutura correta do formato

## Estrutura do repositório

- `odsclass.prg` — classe para geração de arquivos ODS
- `odtclass.prg` — classe para geração de arquivos ODT
- `docclass.prg` — classe para geração de arquivos DOCX
- `xlsclass.prg` — suporte relacionado a planilhas/compatibilidade
- `pdf.prg` — módulo de geração/integração PDF
- `cnvformatos.prg`, `disk61.prg`, `dumyzebra.prg`, `flib08.prg` — utilitários e complementos
- `teste/` — exemplos e testes locais

## Requisitos

- Harbour compiler
- Biblioteca `hbmzip` disponível no ambiente Harbour
- Compatível com Windows e Linux, conforme a instalação do Harbour

## Exemplo: gerando uma planilha ODS

```harbour
#require "hbmzip"

PROCEDURE Main()
   LOCAL oODS, oSheet

   oODS := WorkBookODS():New( "relatorio_vendas.ods" )
   oSheet := oODS:WorkSheet( "Vendas" )

   oSheet:Cell( "A1", "Código" )
   oSheet:Cell( "B1", "Produto" )
   oSheet:Cell( "C1", "Valor" )
   oSheet:Cell( "D1", "Data" )
   oSheet:Cell( "E1", "Ativo" )

   oSheet:Cell( "A2", 101 )
   oSheet:Cell( "B2", "Teclado Mecânico" )
   oSheet:Cell( "C2", 250.00 )
   oSheet:Cell( "D2", Date() )
   oSheet:Cell( "E2", .T. )

   oODS:Save()
   OutStd( "Planilha gerada com sucesso!" )
RETURN
```

## Exemplo: gerando um documento ODT

```harbour
#require "hbmzip"

PROCEDURE Main()
   LOCAL oDoc

   oDoc := DocumentODT():New( "relatorio_gerencial.odt" )
   oDoc:AddHeading( "Relatório Gerencial do Sistema", 1 )
   oDoc:AddParagraph( "Este documento foi gerado 100% nativamente utilizando Harbour puro." )
   oDoc:AddParagraph( "[B]Destaque em negrito[/B] e [I]itálico[/I] em texto simples." )
   oDoc:Save()

   OutStd( "Documento gerado com sucesso!" )
RETURN
```

## Observações técnicas

Os arquivos gerados seguem estruturas abertas do padrão OASIS / Open XML, com elementos essenciais como:

- `mimetype`
- `content.xml`
- `META-INF/manifest.xml`
- arquivos ZIP compactados corretamente

Isso permite que os documentos sejam abertos por aplicativos compatíveis sem necessidade de conversão extra.

## Uso recomendado

Para integrar esta biblioteca em aplicações Harbour, normalmente basta incluir o arquivo `.prg` correspondente no projeto e chamar as classes pelos seus nomes públicos:

```harbour
#include "odsclass.prg"
#include "odtclass.prg"
#include "docclass.prg"
```

Em seguida, instancie a classe desejada e chame `New()` para definir o nome do arquivo de saída e `Save()` para finalizar e gerar o documento.

## Licença

Este repositório é um projeto de código livre para uso e adaptação em aplicações Harbour e relatórios automáticos. A intenção é facilitar a geração de documentos funcionais sem dependência de ferramentas externas pesadas.

Se você quiser contribuir ou adaptar a biblioteca, é possível usar o código como base para projetos comerciais, acadêmicos ou pessoais.
