/*
 * ODT Writer Class - Pure Harbour 
 * Baseado na filosofia da ODS Class para gerar OpenDocument Text nativos
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
ENDCLASS

METHOD New( cName ) CLASS DocumentODT
   LOCAL cDir := CurDir()
   LOCAL nPos
   
   // Formata o caminho do arquivo
   nPos := RAt( hb_PS(), cName )
   ::cFilePath := iif( nPos == 0, DiskName() + hb_OSDriveSeparator() + hb_PS() + cDir + hb_PS(), SubStr(cName, 1, nPos) )
   ::cName := iif( nPos > 0, SubStr(cName, nPos + 1), cName )
   
   ::aContent := {}  
   
   // Prepara diretorio temporario
   ::cTempDir := hb_DirSepToOS( hb_DirTemp() + "OdtTemp_" + hb_ValToStr(hb_RandomInt(1000, 9999)) )
   hb_DirRemoveAll( ::cTempDir )
   MakeDir( ::cTempDir )
Return Self

METHOD AddHeading( cText, nLevel ) CLASS DocumentODT
   // Se o nivel nao for informado, assume Titulo 1
   IF Empty( nLevel ) .OR. ValType( nLevel ) != "N"
      nLevel := 1
   ENDIF
   // Guarda o tipo (H), o nivel (1, 2, 3...) e o texto
   AAdd( ::aContent, { "H", nLevel, cText } )
Return Self

METHOD AddParagraph( cText ) CLASS DocumentODT
   // Guarda o tipo (P) e o texto
   AAdd( ::aContent, { "P", 0, cText } )
Return Self

METHOD Save() CLASS DocumentODT
   LOCAL cSep := hb_ps(), hZip
   LOCAL cManifest, cContent, cMime
   LOCAL nI, eValor, cType
   LOCAL cFinalZip := ::cFilePath + ::cName

   MakeDir( ::cTempDir + cSep + "META-INF" )

   // 1. Mimetype (DEVE SER TEXTO PURO)
   cMime := "application/vnd.oasis.opendocument.text"
   hb_MemoWrit( ::cTempDir + cSep + "mimetype", cMime )

   // 2. manifest.xml
   cManifest := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
                '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>' + hb_osNewLine() + ;
                '</manifest:manifest>'
   hb_MemoWrit( ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", cManifest )

   // 3. content.xml (Onde fica o texto do documento)
   cContent := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
               '<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ' + ;
               'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" office:version="1.2">' + hb_osNewLine() + ;
               ' <office:body>' + hb_osNewLine() + ;
               '  <office:text>' + hb_osNewLine()

   // Varre todo o conteudo adicionado no array
   FOR nI := 1 TO Len( ::aContent )
      cType  := ::aContent[nI, 1]
      eValor := ::aContent[nI, 3]
      
      // Limpeza basica de string para XML nao quebrar
      eValor := StrTran( hb_ValToStr(eValor), "&", "&amp;" )
      eValor := StrTran( eValor, "<", "&lt;" )
      eValor := StrTran( eValor, ">", "&gt;" )

      IF cType == "H" // Adiciona Titulo
         cContent += '   <text:h text:outline-level="' + hb_ValToStr(::aContent[nI, 2]) + '">' + eValor + '</text:h>' + hb_osNewLine()
      ELSEIF cType == "P" // Adiciona Paragrafo normal
         cContent += '   <text:p>' + eValor + '</text:p>' + hb_osNewLine()
      ENDIF
   NEXT

   cContent += '  </office:text>' + hb_osNewLine() + ;
               ' </office:body>' + hb_osNewLine() + ;
               '</office:document-content>'
               
   hb_MemoWrit( ::cTempDir + cSep + "content.xml", cContent )

   // 4. Compactacao do arquivo ODT
   IF File( cFinalZip ); FErase( cFinalZip ); ENDIF
   
   hZip := hb_zipOpen( cFinalZip )
   IF !Empty( hZip )
      // REQUISITO ODT: mimetype não pode ser compactado (compressao Nível 0)
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "mimetype", "mimetype", 0, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "content.xml", "content.xml", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", "META-INF/manifest.xml", 8, .T. )
      hb_zipClose( hZip )
   ENDIF

   // Limpeza da pasta temporaria
   hb_DirRemoveAll( ::cTempDir )
Return Self