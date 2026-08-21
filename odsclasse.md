Aqui está um **README.md** profissional e detalhado para documentar as características, a estrutura e o uso da classe **`WorkBookODS`** (geradora de arquivos `.ods` para LibreOffice / OpenOffice em Harbour puro).

---

```markdown
# 📊 ODS Writer Class for Harbour

Uma classe leve, robusta e **100% em Harbour puro** desenvolvida para criar e exportar planilhas no formato **ODS (OpenDocument Spreadsheet)**, compatível com LibreOffice Calc, Apache OpenOffice e Microsoft Excel.

Esta classe elimina a necessidade de dependências externas complexas, automações OLE pesadas ou DLLs de terceiros, utilizando o motor de compactação nativo (`hbmzip`) do Harbour para estruturar o padrão aberto OASIS.

---

## ✨ Principais Características

* **Zero Dependências Externas:** Não exige o LibreOffice instalado na máquina nem bibliotecas em C/Rust problemáticas.
* **100% Harbour:** Escrita nativamente em Harbour, garantindo portabilidade entre Windows e Linux.
* **Múltiplas Abas (Worksheets):** Suporte a criação de várias planilhas independentes dentro do mesmo documento.
* **Conversão Automática de Tipos:** Detecta e mapeia automaticamente tipos de dados do Harbour (`Caracter`, `Numérico`, `Data`, `Lógico`) para os atributos XML corretos do padrão ODS (`string`, `float`, `date`, `boolean`).
* **Cononformidade com o Padrão ODS:** Implementa corretamente a regra de armazenamento do arquivo `mimetype` sem compressão (nível 0), garantindo que o LibreOffice abra o arquivo sem erros de formato.

---

## 🚀 Como Utilizar

Abaixo encontra-se um exemplo prático de como instanciar a classe, adicionar dados a uma planilha e salvar o arquivo final `.ods`.

```harbour
#require "hbmzip"

PROCEDURE Main()
   LOCAL oODS, oSheet
   
   // 1. Inicializa o Workbook passando o caminho e nome do arquivo
   oODS := WorkBookODS():New( "relatorio_vendas.ods" )
   
   // 2. Cria ou seleciona uma aba (WorkSheet)
   oSheet := oODS:WorkSheet( "Vendas" )
   
   // 3. Adiciona dados informando a célula (Ex: "A1", "B1")
   oSheet:Cell( "A1", "Código" )
   oSheet:Cell( "B1", "Produto" )
   oSheet:Cell( "C1", "Valor" )
   oSheet:Cell( "D1", "Data" )
   oSheet:Cell( "E1", "Ativo" )
   
   // Preenchendo com dados de exemplo
   oSheet:Cell( "A2", 101 )
   oSheet:Cell( "B2", "Teclado Mecânico" )
   oSheet:Cell( "C2", 250.00 )
   oSheet:Cell( "D2", Date() )
   oSheet:Cell( "E2", .T. )
   
   // 4. Salva o arquivo final compactado no disco
   oODS:Save()
   
   OutStd( "Planilha gerada com sucesso!" )
RETURN

```

---

## 📖 Referência de Métodos

### `WorkBookODS` (Classe Principal)

* **`New( cFileName )`**
Inicializa o documento ODS. Define o caminho e o nome do arquivo de saída, além de preparar um diretório temporário para a montagem dos arquivos XML.
* **`WorkSheet( cName )`**
Cria uma nova aba com o nome especificado ou retorna uma aba existente caso o nome já tenha sido criado.
* **`Save()`**
Gera a estrutura de arquivos XML (`mimetype`, `content.xml`, `META-INF/manifest.xml`), compacta tudo utilizando a biblioteca `hbmzip` no formato `.ods` e limpa os arquivos temporários da máquina.

### `WorkSheetODS` (Classe de Aba/Planilha)

* **`Cell( uAddr, xValue )`**
Atribui ou lê o valor de uma célula específica.
* `uAddr`: Coordenada em formato de string alfanumérica (Ex: `"A1"`, `"B12"`).
* `xValue`: O dado a ser gravado (`C`, `N`, `D`, `L`). Caso omitido ou passado como `NIL`, o método atua como leitura da célula.



---

## 🛠️ Detalhes Técnicos de Implementação

1. **Estrutura do Pacote ODS:** Por baixo dos panos, o arquivo `.ods` gerado é um arquivo `.zip` contendo:
* `mimetype`: Armazenado obrigatoriamente sem compressão no início do arquivo.
* `content.xml`: Contém o corpo corporativo da planilha (`<office:spreadsheet>`) com as respectivas linhas (`<table:table-row>`) e células (`<table:table-cell>`).
* `META-INF/manifest.xml`: Arquivo de manifesto obrigatório exigido pelo padrão OpenDocument.


2. **Conversor de Endereçamento (`OdsCellRC`):** A classe possui uma função interna otimizada em Harbour puro que converte coordenadas textuais de colunas (como `A`, `Z`, `AA`, `AB`) em índices numéricos de matrizes sem depender de scripts externos em C (`#pragma BEGINDUMP`).

---

## 📄 Licença

Este código é de uso livre 

```

```