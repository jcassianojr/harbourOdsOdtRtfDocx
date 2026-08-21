# 📄 ODT Writer Class for Harbour

Uma classe leve, robusta e **100% em Harbour puro** desenvolvida para criar e exportar documentos de texto no formato **ODT (OpenDocument Text)**, compatível com LibreOffice Writer, Apache OpenOffice e Microsoft Word.

Assim como a sua contraparte para planilhas (`WorkBookODS`), esta classe elimina a necessidade de dependências externas complexas ou automações OLE pesadas, utilizando o motor de compactação nativo (`hbmzip`) do Harbour para estruturar o padrão aberto OASIS.

---

## ✨ Principais Características

* **Zero Dependências Externas:** Não exige o LibreOffice instalado na máquina nem bibliotecas em C/Rust problemáticas.
* **100% Harbour:** Escrita nativamente em Harbour, garantindo portabilidade perfeita entre Windows e Linux.
* **Estrutura Baseada em Blocos:** Suporte nativo à adição sequencial de Títulos (`AddHeading`) e Parágrafos (`AddParagraph`).
* **Conformidade com o Padrão ODT:** Implementa corretamente a regra de armazenamento do arquivo `mimetype` sem compressão (nível 0), garantindo que o LibreOffice abra o documento sem erros de formato.

---

## 🚀 Como Utilizar

Abaixo encontra-se um exemplo prático de como instanciar a classe, adicionar títulos, parágrafos e salvar o documento final `.odt`.

```harbour
#require "hbmzip"

PROCEDURE Main()
   LOCAL oDoc
   
   // 1. Inicializa o documento passando o caminho e nome do arquivo
   oDoc := DocumentODT():New( "relatorio_gerencial.odt" )
   
   // 2. Adiciona um título principal (Nível 1)
   oDoc:AddHeading( "Relatório Gerencial do Sistema", 1 )
   
   // 3. Adiciona parágrafos de texto
   oDoc:AddParagraph( "Este documento foi gerado 100% nativamente utilizando Harbour puro." )
   oDoc:AddParagraph( "Não há necessidade de DLLs externas ou automação de escritório." )
   
   // Adiciona um subtítulo (Nível 2)
   oDoc:AddHeading( "Detalhes Técnicos", 2 )
   oDoc:AddParagraph( "A estrutura interna segue o padrão aberto OASIS OpenDocument." )
   
   // 4. Salva o arquivo final compactado no disco
   oDoc:Save()
   
   OutStd( "Documento gerado com sucesso!" )
RETURN

```

---

## 📖 Referência de Métodos

### `DocumentODT` (Classe Principal)

* **`New( cFileName )`**
Inicializa o documento ODT. Define o caminho e o nome do arquivo de saída, além de preparar um diretório temporário para a montagem dos arquivos XML.
* **`AddHeading( cText, nLevel )`**
Adiciona um título formatado ao documento.
* `cText`: O texto do título.
* `nLevel`: O nível hierárquico do título (ex: `1` para Título Principal, `2` para Subtítulo). Caso omitido, assume o nível `1` por padrão.


* **`AddParagraph( cText )`**
Adiciona um parágrafo de texto normal logo abaixo do conteúdo anterior.
* **`Save()`**
Gera a estrutura de arquivos XML obrigatórios (`mimetype`, `content.xml`, `META-INF/manifest.xml`), compacta tudo utilizando a biblioteca `hbmzip` no formato `.odt` e limpa os arquivos temporários da máquina.

---

## 🛠️ Detalhes Técnicos de Implementação

1. **Estrutura do Pacote ODT:** Por baixo dos panos, o arquivo `.odt` gerado é um arquivo `.zip` contendo:
* `mimetype`: Armazenado obrigatoriamente sem compressão no início do arquivo (`application/vnd.oasis.opendocument.text`).
* `content.xml`: Contém o corpo de texto estruturado dentro de tags do padrão OASIS (`<office:text>`), convertendo títulos (`<text:h>`) e parágrafos (`<text:p>`).
* `META-INF/manifest.xml`: Arquivo de manifesto obrigatório exigido pelo formato OpenDocument.



---

## 📄 Licença

Este código é de uso livre e pode ser integrado a sistemas comerciais, geradores de relatórios e utilitários em Harbour.