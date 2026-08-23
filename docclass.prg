/*
 * DOCX Writer Class - Pure Harbour 
 * Gera relatorios Word Nativos (.docx) sem Microsoft Office instalado.
 * Suporte nativo a formatacao BBCode ([B], [I], [U], [SIZE], [PAGE])
 */

#require "hbmzip"
#include "simpleio.ch"
#INCLUDE "hbclass.ch"

REQUEST HB_CODEPAGE_UTF8EX

CLASS DocumentDOCX
   DATA cTempDir PROTECTED
   DATA cName
   DATA cFilePath
   DATA aContent PROTECTED  
   
   METHOD New( cName )
   METHOD AddParagraph( cText )
   METHOD Save()
   
   // Metodos internos de parser OpenXML (DOCX)
   METHOD ParseBBCodeToXML( cLinha ) PROTECTED
   METHOD GenerateRun( cText, lBold, lItalic, lUnder, cSize ) PROTECTED
ENDCLASS

METHOD New( cName ) CLASS DocumentDOCX
   LOCAL cDir := CurDir()
   LOCAL nPos
   
   nPos := RAt( hb_PS(), cName )
   ::cFilePath := iif( nPos == 0, DiskName() + hb_OSDriveSeparator() + hb_PS() + cDir + hb_PS(), SubStr(cName, 1, nPos) )
   ::cName := iif( nPos > 0, SubStr(cName, nPos + 1), cName )
   
   ::aContent := {}  
   
   // Diretorio temporario para montar a estrutura ZIP do DOCX
   ::cTempDir := hb_DirSepToOS( hb_DirTemp() + "DocxTemp_" + hb_ValToStr(hb_RandomInt(1000, 9999)) )
   hb_DirRemoveAll( ::cTempDir )
   MakeDir( ::cTempDir )
Return Self

METHOD AddParagraph( cText ) CLASS DocumentDOCX
   AAdd( ::aContent, cText )
Return Self

METHOD Save() CLASS DocumentDOCX
   LOCAL cSep := hb_ps(), hZip
   LOCAL cContentTypes, cRels, cDocRels, cContent
   LOCAL nI, eValor, cParProps
   LOCAL cFinalZip := ::cFilePath + ::cName

   // Cria a arvore de diretorios obrigatoria do DOCX
   MakeDir( ::cTempDir + cSep + "_rels" )
   MakeDir( ::cTempDir + cSep + "word" )
   MakeDir( ::cTempDir + cSep + "word" + cSep + "_rels" )

   // 1. [Content_Types].xml
   cContentTypes := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
                    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' + hb_osNewLine() + ;
                    ' <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' + hb_osNewLine() + ;
                    ' <Default Extension="xml" ContentType="application/xml"/>' + hb_osNewLine() + ;
                    ' <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' + hb_osNewLine() + ;
                    '</Types>'
   hb_MemoWrit( ::cTempDir + cSep + "[Content_Types].xml", cContentTypes )

   // 2. _rels/.rels
   cRels := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + hb_osNewLine() + ;
            ' <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>' + hb_osNewLine() + ;
            '</Relationships>'
   hb_MemoWrit( ::cTempDir + cSep + "_rels" + cSep + ".rels", cRels )

   // 3. Documento Principal XML (word/document.xml)
   cContent := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
               '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' + hb_osNewLine() + ;
               ' <w:body>' + hb_osNewLine()

   // Laco de criacao dos Paragrafos
   FOR nI := 1 TO Len( ::aContent )
      eValor    := hb_ValToStr(::aContent[nI])
      cParProps := ""
      
      // A. Limpeza basica de pituacoes do XML
      eValor := StrTran( eValor, "&", "&amp;" )
      eValor := StrTran( eValor, "<", "&lt;" )
      eValor := StrTran( eValor, ">", "&gt;" )

      // B. Tratamento de Salto de Pagina Nativo do Word
      IF "[PAGE]" $ eValor
         cParProps := '<w:pPr><w:pageBreakBefore/></w:pPr>'
         eValor := StrTran( eValor, "[PAGE]", "" ) 
      ENDIF

      // C. Substituicao do BBCode por nos (nodes) Word Run (<w:r>)
      eValor := ::ParseBBCodeToXML( eValor )
      
      // No Word, linhas em branco sem <w:r> as vezes sao esmagadas. 
      // Garantimos um espaco invisivel se a linha estiver vazia apos o Parse.
      IF Empty( eValor )
         eValor := ::GenerateRun( " ", .F., .F., .F., "" )
      ENDIF

      // Insere o Paragrafo
      cContent += '  <w:p>' + cParProps + eValor + '</w:p>' + hb_osNewLine()
   NEXT

   cContent += ' </w:body>' + hb_osNewLine() + ;
               '</w:document>'
               
   hb_MemoWrit( ::cTempDir + cSep + "word" + cSep + "document.xml", cContent )

   // 4. Compactacao do arquivo .DOCX
   IF File( cFinalZip ); FErase( cFinalZip ); ENDIF
   hZip := hb_zipOpen( cFinalZip )
   IF !Empty( hZip )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "[Content_Types].xml", "[Content_Types].xml", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "_rels" + cSep + ".rels", "_rels/.rels", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "word" + cSep + "document.xml", "word/document.xml", 8, .T. )
      hb_zipClose( hZip )
   ENDIF

   // Limpeza
   hb_DirRemoveAll( ::cTempDir )
Return Self

// ---------------------------------------------------------
// DOCX Machine State (Interpretador de BBCode)
// Em vez de abrir e fechar tags envolventes, o Word usa "Runs" repetitivos
// ---------------------------------------------------------
METHOD ParseBBCodeToXML( cLinha ) CLASS DocumentDOCX
   LOCAL cResult := ""
   LOCAL nPosIni, nPosFim, cTag, cCmd
   LOCAL lBold := .F., lItalic := .F., lUnder := .F.
   LOCAL cSize := ""

   WHILE !Empty( cLinha )
      nPosIni := At( "[", cLinha )
      IF nPosIni > 0
         // Existe texto ANTES da tag. Imprimimos com as propriedades atuais!
         IF nPosIni > 1
            cResult += ::GenerateRun( SubStr( cLinha, 1, nPosIni - 1 ), lBold, lItalic, lUnder, cSize )
         ENDIF

         nPosFim := hb_At( "]", cLinha, nPosIni )
         IF nPosFim > 0
            cTag := SubStr( cLinha, nPosIni + 1, nPosFim - nPosIni - 1 )
            cCmd := Upper( cTag )

            DO CASE
               CASE cCmd == "B";  lBold   := .T.
               CASE cCmd == "/B"; lBold   := .F.
               CASE cCmd == "I";  lItalic := .T.
               CASE cCmd == "/I"; lItalic := .F.
               CASE cCmd == "U";  lUnder  := .T.
               CASE cCmd == "/U"; lUnder  := .F.
               CASE Left( cCmd, 5 ) == "SIZE="
                  // O Word trabalha com fontes em MEIO-PONTOS. Fonte 12pt = Valor 24 no XML.
                  cSize := hb_ValToStr( Val( SubStr( cCmd, 6 ) ) * 2 )
               CASE Left( cCmd, 5 ) == "/SIZE"
                  cSize := ""
            ENDCASE

            cLinha := SubStr( cLinha, nPosFim + 1 )
         ELSE
            cResult += ::GenerateRun( cLinha, lBold, lItalic, lUnder, cSize )
            cLinha := ""
         ENDIF
      ELSE
         cResult += ::GenerateRun( cLinha, lBold, lItalic, lUnder, cSize )
         cLinha := ""
      ENDIF
   ENDDO

RETURN cResult

// ---------------------------------------------------------
// Fabrica de "Runs" (Pedaços de texto renderizavel)
// ---------------------------------------------------------
METHOD GenerateRun( cText, lBold, lItalic, lUnder, cSize ) CLASS DocumentDOCX
   LOCAL cRun := "<w:r>"
   LOCAL cProps := ""

   // Fonte Monoespaçada padrao (Courier New) forçada em todos os pedacos para manter as colunas
   cProps += '<w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"/>'

   IF lBold
      cProps += "<w:b/>"
   ENDIF
   
   IF lItalic
      cProps += "<w:i/>"
   ENDIF
   
   IF lUnder
      cProps += '<w:u w:val="single"/>'
   ENDIF
   
   IF !Empty( cSize )
      cProps += '<w:sz w:val="' + cSize + '"/>' + '<w:szCs w:val="' + cSize + '"/>'
   ENDIF

   IF !Empty( cProps )
      cRun += "<w:rPr>" + cProps + "</w:rPr>"
   ENDIF

   // xml:space="preserve" eh CRITICO para relatorios textuais do DOS, senao o Word come espacos!
   cRun += '<w:t xml:space="preserve">' + cText + '</w:t>'
   cRun += "</w:r>"
   
RETURN cRun