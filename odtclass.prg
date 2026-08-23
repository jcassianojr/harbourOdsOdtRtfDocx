/*
 * ODT Writer Class - Pure Harbour 
 * Suporte nativo a formatacao BBCode ([B], [I], [U], [SIZE], [PAGE])
 */

#require "hbmzip"
#include "simpleio.ch"
#INCLUDE "hbclass.ch"

REQUEST HB_CODEPAGE_UTF8EX

CLASS DocumentODT
   DATA cTempDir PROTECTED
   DATA cName
   DATA cFilePath
   DATA aContent PROTECTED  
   
   METHOD New( cName )
   METHOD AddHeading( cText, nLevel )
   METHOD AddParagraph( cText )
   METHOD Save()
   
   // Novo metodo interno para processamento seguro do XML
   METHOD ParseBBCodeToXML( cLinha ) PROTECTED
ENDCLASS

METHOD New( cName ) CLASS DocumentODT
   LOCAL cDir := CurDir()
   LOCAL nPos
   
   nPos := RAt( hb_PS(), cName )
   ::cFilePath := iif( nPos == 0, DiskName() + hb_OSDriveSeparator() + hb_PS() + cDir + hb_PS(), SubStr(cName, 1, nPos) )
   ::cName := iif( nPos > 0, SubStr(cName, nPos + 1), cName )
   
   ::aContent := {}  
   
   ::cTempDir := hb_DirSepToOS( hb_DirTemp() + "OdtTemp_" + hb_ValToStr(hb_RandomInt(1000, 9999)) )
   hb_DirRemoveAll( ::cTempDir )
   MakeDir( ::cTempDir )
Return Self

METHOD AddHeading( cText, nLevel ) CLASS DocumentODT
   IF Empty( nLevel ) .OR. ValType( nLevel ) != "N"
      nLevel := 1
   ENDIF
   AAdd( ::aContent, { "H", nLevel, cText } )
Return Self

METHOD AddParagraph( cText ) CLASS DocumentODT
   AAdd( ::aContent, { "P", 0, cText } )
Return Self

METHOD Save() CLASS DocumentODT
   LOCAL cSep := hb_ps(), hZip
   LOCAL cManifest, cContent, cMime
   LOCAL nI, eValor, cType, cParStyle
   LOCAL cFinalZip := ::cFilePath + ::cName

   MakeDir( ::cTempDir + cSep + "META-INF" )

   cMime := "application/vnd.oasis.opendocument.text"
   hb_MemoWrit( ::cTempDir + cSep + "mimetype", cMime )

   cManifest := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
                '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>' + hb_osNewLine() + ;
                '</manifest:manifest>'
   hb_MemoWrit( ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", cManifest )

   // Inclusao dos Namespaces ODT e Estilos Automaticos para suportar o BBCode
   cContent := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
               '<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ' + ;
               'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" ' + ;
               'xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" ' + ;
               'xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" office:version="1.2">' + hb_osNewLine() + ;
               ' <office:automatic-styles>' + hb_osNewLine() + ;
               '  <style:style style:name="T_B" style:family="text"><style:text-properties fo:font-weight="bold"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="T_I" style:family="text"><style:text-properties fo:font-style="italic"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="T_U" style:family="text"><style:text-properties style:text-underline-style="solid" style:text-underline-width="auto" style:text-underline-color="font-color"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="T_S8" style:family="text"><style:text-properties fo:font-size="8pt"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="T_S12" style:family="text"><style:text-properties fo:font-size="12pt"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="T_S14" style:family="text"><style:text-properties fo:font-size="14pt"/></style:style>' + hb_osNewLine() + ;
               '  <style:style style:name="P_PageBreak" style:family="paragraph"><style:paragraph-properties fo:break-before="page"/></style:style>' + hb_osNewLine() + ;
               ' </office:automatic-styles>' + hb_osNewLine() + ;
               ' <office:body>' + hb_osNewLine() + ;
               '  <office:text>' + hb_osNewLine()

   FOR nI := 1 TO Len( ::aContent )
      cType     := ::aContent[nI, 1]
      eValor    := hb_ValToStr(::aContent[nI, 3])
      cParStyle := ""
      
      // 1. Limpeza OBRIGATORIA de strings para XML antes de processar o BBCode
      eValor := StrTran( eValor, "&", "&amp;" )
      eValor := StrTran( eValor, "<", "&lt;" )
      eValor := StrTran( eValor, ">", "&gt;" )

      // 2. Verifica se ha comando de Salto de Pagina na linha
      IF "[PAGE]" $ eValor
         cParStyle := ' text:style-name="P_PageBreak"'
         eValor := StrTran( eValor, "[PAGE]", "" ) // Limpa a tag para nao imprimir
      ENDIF

      // 3. Traduz formatações inline de forma segura
      eValor := ::ParseBBCodeToXML( eValor )

      IF cType == "H" 
         cContent += '   <text:h text:outline-level="' + hb_ValToStr(::aContent[nI, 2]) + '">' + eValor + '</text:h>' + hb_osNewLine()
      ELSEIF cType == "P" 
         cContent += '   <text:p' + cParStyle + '>' + eValor + '</text:p>' + hb_osNewLine()
      ENDIF
   NEXT

   cContent += '  </office:text>' + hb_osNewLine() + ;
               ' </office:body>' + hb_osNewLine() + ;
               '</office:document-content>'
               
   hb_MemoWrit( ::cTempDir + cSep + "content.xml", cContent )

   IF File( cFinalZip ); FErase( cFinalZip ); ENDIF
   hZip := hb_zipOpen( cFinalZip )
   IF !Empty( hZip )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "mimetype", "mimetype", 0, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "content.xml", "content.xml", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", "META-INF/manifest.xml", 8, .T. )
      hb_zipClose( hZip )
   ENDIF

   hb_DirRemoveAll( ::cTempDir )
Return Self

// ---------------------------------------------------------
// Parser Seguro de Tokens para XML ODT
// ---------------------------------------------------------
METHOD ParseBBCodeToXML( cLinha ) CLASS DocumentODT
   LOCAL cResult := ""
   LOCAL nPosIni, nPosFim, cTag, cCmd
   LOCAL nSizeOpen := 0, nBoldOpen := 0, nItalicOpen := 0, nUnderOpen := 0

   WHILE !Empty( cLinha )
      nPosIni := At( "[", cLinha )
      IF nPosIni > 0
         IF nPosIni > 1
            cResult += SubStr( cLinha, 1, nPosIni - 1 )
         ENDIF

         nPosFim := At( "]", cLinha, nPosIni )
         IF nPosFim > 0
            cTag := SubStr( cLinha, nPosIni + 1, nPosFim - nPosIni - 1 )
            cCmd := Upper( cTag )

            DO CASE
               CASE cCmd == "B"
                  cResult += '<text:span text:style-name="T_B">'
                  nBoldOpen++
               CASE cCmd == "/B"
                  IF nBoldOpen > 0
                     cResult += '</text:span>'
                     nBoldOpen--
                  ENDIF
               CASE cCmd == "I"
                  cResult += '<text:span text:style-name="T_I">'
                  nItalicOpen++
               CASE cCmd == "/I"
                  IF nItalicOpen > 0
                     cResult += '</text:span>'
                     nItalicOpen--
                  ENDIF
               CASE cCmd == "U"
                  cResult += '<text:span text:style-name="T_U">'
                  nUnderOpen++
               CASE cCmd == "/U"
                  IF nUnderOpen > 0
                     cResult += '</text:span>'
                     nUnderOpen--
                  ENDIF
               CASE Left( cCmd, 5 ) == "SIZE="
                  // Se ja havia um tamanho aberto, fecha antes de abrir o proximo (Evita tag aninhada)
                  IF nSizeOpen > 0
                     cResult += '</text:span>' 
                     nSizeOpen--
                  ENDIF
                  cResult += '<text:span text:style-name="T_S' + SubStr( cCmd, 6 ) + '">'
                  nSizeOpen++
               CASE Left( cCmd, 6 ) == "/SIZE"
                  IF nSizeOpen > 0
                     cResult += '</text:span>'
                     nSizeOpen--
                  ENDIF
            ENDCASE

            cLinha := SubStr( cLinha, nPosFim + 1 )
         ELSE
            cResult += cLinha
            cLinha := ""
         ENDIF
      ELSE
         cResult += cLinha
         cLinha := ""
      ENDIF
   ENDDO

   // Protecao Contra Corrupcao de ODT: Fecha compulsoriamente tags orfãs no fim da linha
   WHILE nBoldOpen > 0;   cResult += '</text:span>'; nBoldOpen--;   ENDDO
   WHILE nItalicOpen > 0; cResult += '</text:span>'; nItalicOpen--; ENDDO
   WHILE nUnderOpen > 0;  cResult += '</text:span>'; nUnderOpen--;  ENDDO
   WHILE nSizeOpen > 0;   cResult += '</text:span>'; nSizeOpen--;   ENDDO

RETURN cResult