/*
 * ODS writer Class - Pure Harbour 
 * Baseado na filosofia da XLSX Class para gerar OpenDocument Spreadsheets nativos
 */

#require "hbmzip"
#include "simpleio.ch"
#INCLUDE "hbclass.ch"

REQUEST HB_CODEPAGE_UTF8EX

CLASS WorkBookODS
   DATA cTempDir PROTECTED
   DATA cName
   DATA cFilePath
   DATA aWorkSheetNames PROTECTED  
   DATA aWorkSheetObjects PROTECTED 
   
   METHOD New( cName )
   METHOD WorkSheet( cName )
   METHOD GetTempDir()
   METHOD Save()
ENDCLASS

METHOD New( cName ) CLASS WorkBookODS
   LOCAL cDir := CurDir()
   
   // Formata o caminho do arquivo
   ::cFilePath := iif( FilePath(cName) == "", DiskName() + hb_OSDriveSeparator() + hb_PS() + cDir + hb_PS() , FilePath(cName) )
   ::cName := iif( At(::cFilePath, cName) > 0, SubStr(cName, Len(::cFilePath) + 1), cName )
   
   ::aWorkSheetNames := {}  
   ::aWorkSheetObjects := {}
   
   // Prepara diretorio temporario
   ::cTempDir := hb_DirSepToOS( hb_DirTemp() + "OdsTemp_" + hb_ValToStr(hb_RandomInt(1000, 9999)) )
   hb_DirRemoveAll( ::cTempDir )
   MakeDir( ::cTempDir )
Return Self

METHOD WorkSheet( cName ) CLASS WorkBookODS
   LOCAL oWorkSheet, nPos 
   IF ( nPos := AScan( ::aWorkSheetNames, cName ) ) == 0
      oWorkSheet := WorkSheetODS():New( cName )
      oWorkSheet:oParent := Self
      AAdd( ::aWorkSheetNames, cName )
      AAdd( ::aWorkSheetObjects, oWorkSheet )
      nPos := Len( ::aWorkSheetNames )
   ENDIF
Return ::aWorkSheetObjects[nPos]

METHOD GetTempDir() CLASS WorkBookODS
Return ::cTempDir

METHOD Save() CLASS WorkBookODS
   LOCAL cSep := hb_ps(), hZip
   LOCAL cManifest, cContent, cMime
   LOCAL nI, nJ, nK, aData, eValor
   LOCAL cFinalZip := ::cFilePath + ::cName

   MakeDir( ::cTempDir + cSep + "META-INF" )

   // 1. Mimetype (DEVE SER TEXTO PURO)
   cMime := "application/vnd.oasis.opendocument.spreadsheet"
   hb_MemoWrit( ::cTempDir + cSep + "mimetype", cMime )

   // 2. manifest.xml
   cManifest := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
                '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.spreadsheet"/>' + hb_osNewLine() + ;
                ' <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>' + hb_osNewLine() + ;
                '</manifest:manifest>'
   hb_MemoWrit( ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", cManifest )

   // 3. content.xml (Onde ficam todas as planilhas e dados)
   cContent := '<?xml version="1.0" encoding="UTF-8"?>' + hb_osNewLine() + ;
               '<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ' + ;
               'xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" ' + ;
               'xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" office:version="1.2">' + hb_osNewLine() + ;
               ' <office:body>' + hb_osNewLine() + ;
               '  <office:spreadsheet>' + hb_osNewLine()

   // Varre todas as WorkSheets criadas
   FOR nI := 1 TO Len( ::aWorkSheetNames )
      cContent += '   <table:table table:name="' + ::aWorkSheetNames[nI] + '">' + hb_osNewLine()
      
      aData := ::aWorkSheetObjects[nI]:aData
      FOR nJ := 1 TO Len( aData )
         cContent += '    <table:table-row>' + hb_osNewLine()
         
         IF Len( aData[nJ] ) > 0
            FOR nK := 1 TO Len( aData[nJ] )
               eValor := aData[nJ, nK]
               
               IF eValor == NIL
                  cContent += '     <table:table-cell/>' + hb_osNewLine()
               ELSEIF ValType( eValor ) == "N"
                  cContent += '     <table:table-cell office:value-type="float" office:value="' + hb_ValToStr(eValor) + '"><text:p>' + hb_ValToStr(eValor) + '</text:p></table:table-cell>' + hb_osNewLine()
               ELSEIF ValType( eValor ) == "D"
                  cContent += '     <table:table-cell office:value-type="date" office:date-value="' + StrZero(Year(eValor),4) + '-' + StrZero(Month(eValor),2) + '-' + StrZero(Day(eValor),2) + '"><text:p>' + DToC(eValor) + '</text:p></table:table-cell>' + hb_osNewLine()
               ELSEIF ValType( eValor ) == "L"
                  cContent += '     <table:table-cell office:value-type="boolean" office:boolean-value="' + iif(eValor, 'true', 'false') + '"><text:p>' + iif(eValor, 'VERDADEIRO', 'FALSO') + '</text:p></table:table-cell>' + hb_osNewLine()
               ELSE
                  // String format
                  eValor := StrTran( hb_ValToStr(eValor), "&", "&amp;" )
                  eValor := StrTran( eValor, "<", "&lt;" )
                  eValor := StrTran( eValor, ">", "&gt;" )
                  cContent += '     <table:table-cell office:value-type="string"><text:p>' + eValor + '</text:p></table:table-cell>' + hb_osNewLine()
               ENDIF
            NEXT
         ENDIF
         cContent += '    </table:table-row>' + hb_osNewLine()
      NEXT
      cContent += '   </table:table>' + hb_osNewLine()
   NEXT

   cContent += '  </office:spreadsheet>' + hb_osNewLine() + ;
               ' </office:body>' + hb_osNewLine() + ;
               '</office:document-content>'
               
   hb_MemoWrit( ::cTempDir + cSep + "content.xml", cContent )

   // 4. Compactação
   IF File( cFinalZip ); FErase( cFinalZip ); ENDIF
   
   hZip := hb_zipOpen( cFinalZip )
   IF !Empty( hZip )
      // REQUISITO ODS: mimetype não pode ser compactado (Nível 0)
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "mimetype", "mimetype", 0, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "content.xml", "content.xml", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "META-INF" + cSep + "manifest.xml", "META-INF/manifest.xml", 8, .T. )
      hb_zipClose( hZip )
   ENDIF

   // Limpeza
   hb_DirRemoveAll( ::cTempDir )
Return Self


CLASS WorkSheetODS
   DATA cName
   DATA oParent
   DATA nMaxRow PROTECTED
   DATA nMaxCol PROTECTED
   DATA aData   // Matriz de dados
   
   METHOD New( cName )
   METHOD Cell( uAddr, xValue )
ENDCLASS

METHOD New( cName ) CLASS WorkSheetODS
   ::cName := cName
   ::aData := {}
   ::nMaxRow := 0
   ::nMaxCol := 0
Return Self

METHOD Cell( uAddr, xValue ) CLASS WorkSheetODS
   LOCAL nRow := 0, nCol := 0, nI
   
   // Converte endereço "A1" para linha e coluna nativamente
   IF ValType( uAddr ) == "A"
      nRow := uAddr[1]
      nCol := uAddr[2]
   ELSE
      OdsCellRC( uAddr, @nRow, @nCol )
   ENDIF

   ::nMaxCol := iif( nCol > ::nMaxCol, nCol, ::nMaxCol )
   ::nMaxRow := iif( nRow > ::nMaxRow, nRow, ::nMaxRow )

   // Ajusta o tamanho da matriz verticalmente
   IF Len( ::aData ) < nRow
      FOR nI := Len( ::aData ) + 1 TO nRow 
         AAdd( ::aData, {} )
      NEXT
   ENDIF

   // Ajusta o tamanho da matriz horizontalmente para a linha atual
   IF Len( ::aData[nRow] ) < nCol
      FOR nI := Len( ::aData[nRow] ) + 1 TO nCol
         AAdd( ::aData[nRow], NIL )
      NEXT
   ENDIF

   IF xValue != NIL
      ::aData[nRow, nCol] := xValue
   ENDIF
   
Return ::aData[nRow, nCol]


// Função auxiliar para evitar necessidade de #pragma BEGINDUMP em C
STATIC FUNCTION OdsCellRC( cAddr, nRow, nCol )
   LOCAL nI := 1, nLen := Len( cAddr ), cChar
   LOCAL nTempCol := 0
   
   cAddr := Upper( cAddr )
   
   WHILE nI <= nLen
      cChar := SubStr( cAddr, nI, 1 )
      IF cChar >= "A" .AND. cChar <= "Z"
         nTempCol := ( nTempCol * 26 ) + ( Asc( cChar ) - Asc( "A" ) + 1 )
      ELSE
         EXIT
      ENDIF
      nI++
   ENDDO
   
   nCol := nTempCol
   nRow := Val( SubStr( cAddr, nI ) )
RETURN NIL

STATIC FUNCTION FilePath( cFile )
   LOCAL nPos, cFilePath := iif( (nPos := RAt(hb_PS(), cFile)) != 0, SubStr(cFile, 1, nPos), "" )
RETURN cFilePath