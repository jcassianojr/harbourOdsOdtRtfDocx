/*
 * XLSX Writer Class - Pure Harbour 
 * Baseado na filosofia da ODS Class para gerar OpenXML Spreadsheets nativos (.xlsx)
 * Mantém total compatibilidade de stubs e métodos com a interface da WorkBookODS
 */

#require "hbmzip"
#include "simpleio.ch"
#INCLUDE "hbclass.ch"

REQUEST HB_CODEPAGE_UTF8EX

CLASS WorkBookXLSX
   DATA cTempDir PROTECTED
   DATA cName
   DATA cFilePath
   DATA aWorkSheetNames PROTECTED  
   DATA aWorkSheetObjects PROTECTED 
   
   // --- Arrays de Compatibilidade de Estilos ---
   DATA aFonts PROTECTED
   DATA aStyles PROTECTED
   DATA aFills PROTECTED
   DATA aBorders PROTECTED
   DATA aNumFormats PROTECTED
   
   METHOD New( cName )
   METHOD WorkSheet( cName )
   METHOD GetTempDir()
   METHOD Save()
   
   // --- Métodos de Compatibilidade (Stubs) ---
   METHOD NewFormat( cFormat )
   METHOD NewFillPattern( nFillPattern, cFG, cBG )
   METHOD NewFont( cFont, nFontSize, lBold, lItalic, lUnderline, lStrike, cRGB )
   METHOD NewBorder( nTL, nTR, nTT, nTB, nTD, cCL, cCR, cCT, cCB, cCD  )
   METHOD NewStyle( nFont, nBorder, nFill, nVA, nHA, nFormat, nRotation, lWrap )
ENDCLASS

METHOD New( cName ) CLASS WorkBookXLSX
   LOCAL cDir := CurDir()
   
   ::cFilePath := iif( FilePath(cName) == "", DiskName() + hb_OSDriveSeparator() + hb_PS() + cDir + hb_PS() , FilePath(cName) )
   ::cName := iif( At(::cFilePath, cName) > 0, SubStr(cName, Len(::cFilePath) + 1), cName )
   
   ::aWorkSheetNames := {}  
   ::aWorkSheetObjects := {}
   
   ::aFonts := {}
   ::aStyles := {}
   ::aFills := {}
   ::aBorders := {}
   ::aNumFormats := {}
   
   ::cTempDir := hb_DirSepToOS( hb_DirTemp() + "XlsxTemp_" + hb_ValToStr(hb_RandomInt(1000, 9999)) )
   hb_DirRemoveAll( ::cTempDir )
   MakeDir( ::cTempDir )
Return Self

// --- Implementação dos Stubs de Estilo ---
METHOD NewFormat( cFormat ) CLASS WorkBookXLSX
   AAdd( ::aNumFormats, cFormat )
Return Len( ::aNumFormats )

METHOD NewFillPattern( nFillPattern, cFG, cBG ) CLASS WorkBookXLSX
   AAdd( ::aFills, {nFillPattern, cFG, cBG} )
Return Len( ::aFills )

METHOD NewFont( cFont, nFontSize, lBold, lItalic, lUnderline, lStrike, cRGB ) CLASS WorkBookXLSX
   AAdd( ::aFonts, {cFont, nFontSize, lBold, lItalic, lUnderline, lStrike, cRGB} )
Return Len( ::aFonts )

METHOD NewBorder( nTL, nTR, nTT, nTB, nTD, cCL, cCR, cCT, cCB, cCD ) CLASS WorkBookXLSX
   AAdd( ::aBorders, {nTL, nTR, nTT, nTB, nTD, cCL, cCR, cCT, cCB, cCD} )
Return Len( ::aBorders )

METHOD NewStyle( nFont, nBorder, nFill, nVA, nHA, nFormat, nRotation, lWrap ) CLASS WorkBookXLSX
   AAdd( ::aStyles, {nFont, nBorder, nFill, nVA, nHA, nFormat, nRotation, lWrap} )
Return Len( ::aStyles )


METHOD WorkSheet( cName ) CLASS WorkBookXLSX
   LOCAL oWorkSheet, nPos 
   IF ( nPos := AScan( ::aWorkSheetNames, cName ) ) == 0
      oWorkSheet := WorkSheetXLSX():New( cName )
      oWorkSheet:oParent := Self
      AAdd( ::aWorkSheetNames, cName )
      AAdd( ::aWorkSheetObjects, oWorkSheet )
      nPos := Len( ::aWorkSheetNames )
   ENDIF
Return ::aWorkSheetObjects[nPos]

METHOD GetTempDir() CLASS WorkBookXLSX
Return ::cTempDir

METHOD Save() CLASS WorkBookXLSX
   LOCAL cSep := hb_ps(), hZip
   LOCAL cContentTypes, cRels, cWorkbookRels, cWorkbook, cSheetXml
   LOCAL nI, nJ, nK, aData, eValor
   LOCAL cFinalZip := ::cFilePath + ::cName
   LOCAL cColName

   MakeDir( ::cTempDir + cSep + "_rels" )
   MakeDir( ::cTempDir + cSep + "xl" )
   MakeDir( ::cTempDir + cSep + "xl" + cSep + "_rels" )
   MakeDir( ::cTempDir + cSep + "xl" + cSep + "worksheets" )

   // 1. [Content_Types].xml
   cContentTypes := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
                    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' + hb_osNewLine() + ;
                    ' <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' + hb_osNewLine() + ;
                    ' <Default Extension="xml" ContentType="application/xml"/>' + hb_osNewLine() + ;
                    ' <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.workbook+xml"/>' + hb_osNewLine()
   
   FOR nI := 1 TO Len( ::aWorkSheetNames )
      cContentTypes += ' <Override PartName="/xl/worksheets/sheet' + hb_ValToStr(nI) + '.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' + hb_osNewLine()
   NEXT
   cContentTypes += '</Types>'
   hb_MemoWrit( ::cTempDir + cSep + "[Content_Types].xml", cContentTypes )

   // 2. _rels/.rels
   cRels := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + hb_osNewLine() + ;
            ' <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' + hb_osNewLine() + ;
            '</Relationships>'
   hb_MemoWrit( ::cTempDir + cSep + "_rels" + cSep + ".rels", cRels )

   // 3. xl/_rels/workbook.xml.rels
   cWorkbookRels := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
                    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + hb_osNewLine()
   FOR nI := 1 TO Len( ::aWorkSheetNames )
      cWorkbookRels += ' <Relationship Id="rId' + hb_ValToStr(nI) + '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet' + hb_ValToStr(nI) + '.xml"/>' + hb_osNewLine()
   NEXT
   cWorkbookRels += '</Relationships>'
   hb_MemoWrit( ::cTempDir + cSep + "xl" + cSep + "_rels" + cSep + "workbook.xml.rels", cWorkbookRels )

   // 4. xl/workbook.xml
   cWorkbook := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
                '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' + hb_osNewLine() + ;
                ' <sheets>' + hb_osNewLine()
   FOR nI := 1 TO Len( ::aWorkSheetNames )
      cWorkbook += '  <sheet name="' + ::aWorkSheetNames[nI] + '" sheetId="' + hb_ValToStr(nI) + '" r:id="rId' + hb_ValToStr(nI) + '"/>' + hb_osNewLine()
   NEXT
   cWorkbook += ' </sheets>' + hb_osNewLine() + ;
                '</workbook>'
   hb_MemoWrit( ::cTempDir + cSep + "xl" + cSep + "workbook.xml", cWorkbook )

   // 5. Gera cada worksheet em xl/worksheets/sheetN.xml
   FOR nI := 1 TO Len( ::aWorkSheetNames )
      cSheetXml := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + hb_osNewLine() + ;
                   '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' + hb_osNewLine() + ;
                   ' <sheetData>' + hb_osNewLine()
      
      aData := ::aWorkSheetObjects[nI]:aData
      FOR nJ := 1 TO Len( aData )
         cSheetXml += '  <row r="' + hb_ValToStr(nJ) + '">' + hb_osNewLine()
         
         IF Len( aData[nJ] ) > 0
            FOR nK := 1 TO Len( aData[nJ] )
               eValor := aData[nJ, nK]
               cColName := ColIndexToLetter( nK ) + hb_ValToStr( nJ )
               
               IF eValor != NIL
                  IF ValType( eValor ) == "N"
                     cSheetXml += '   <c r="' + cColName + '"><v>' + hb_ValToStr( eValor ) + '</v></c>' + hb_osNewLine()
                  ELSEIF ValType( eValor ) == "D"
                     cSheetXml += '   <c r="' + cColName + '" t="inlineStr"><is><t>' + DToC( eValor ) + '</t></is></c>' + hb_osNewLine()
                  ELSEIF ValType( eValor ) == "L"
                     cSheetXml += '   <c r="' + cColName + '" t="inlineStr"><is><t>' + iif( eValor, "VERDADEIRO", "FALSO" ) + '</t></is></c>' + hb_osNewLine()
                  ELSE
                     eValor := StrTran( hb_ValToStr( eValor ), "&", "&amp;" )
                     eValor := StrTran( eValor, "<", "&lt;" )
                     eValor := StrTran( eValor, ">", "&gt;" )
                     cSheetXml += '   <c r="' + cColName + '" t="inlineStr"><is><t>' + eValor + '</t></is></c>' + hb_osNewLine()
                  ENDIF
               ENDIF
            NEXT
         ENDIF
         cSheetXml += '  </row>' + hb_osNewLine()
      NEXT
      
      cSheetXml += ' </sheetData>' + hb_osNewLine() + ;
                   '</worksheet>'
                   
      hb_MemoWrit( ::cTempDir + cSep + "xl" + cSep + "worksheets" + cSep + "sheet" + hb_ValToStr(nI) + ".xml", cSheetXml )
   NEXT

   // 6. Compactação do pacote ZIP final (.xlsx)
   IF File( cFinalZip ); FErase( cFinalZip ); ENDIF
   
   hZip := hb_zipOpen( cFinalZip )
   If !Empty( hZip )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "[Content_Types].xml", "[Content_Types].xml", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "_rels" + cSep + ".rels", "_rels/.rels", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "xl" + cSep + "_rels" + cSep + "workbook.xml.rels", "xl/_rels/workbook.xml.rels", 8, .T. )
      hb_zipStoreFile( hZip, ::cTempDir + cSep + "xl" + cSep + "workbook.xml", "xl/workbook.xml", 8, .T. )
      
      FOR nI := 1 TO Len( ::aWorkSheetNames )
         hb_zipStoreFile( hZip, ::cTempDir + cSep + "xl" + cSep + "worksheets" + cSep + "sheet" + hb_ValToStr(nI) + ".xml", "xl/worksheets/sheet" + hb_ValToStr(nI) + ".xml", 8, .T. )
      NEXT
      
      hb_zipClose( hZip )
   ENDIF

   hb_DirRemoveAll( ::cTempDir )
Return Self


CLASS WorkSheetXLSX
   DATA cName
   DATA oParent
   DATA nMaxRow PROTECTED
   DATA nMaxCol PROTECTED
   DATA aData   
   DATA aRowsDetail PROTECTED
   
   // --- Propriedades de Compatibilidade ---
   DATA paperSize INIT 9
   DATA lLandscape INIT .F.
   DATA leftMargin INIT 0.5
   DATA rightMargin INIT 0.5
   DATA topMargin INIT 0.5
   DATA bottomMargin INIT 0.5
   
   METHOD New( cName )
   METHOD Cell( uAddr, xValue, nStyle )
   METHOD RowDetail( nRow, nHeight, nStyle, lHide )
ENDCLASS

METHOD New( cName ) CLASS WorkSheetXLSX
   ::cName := cName
   ::aData := {}
   ::aRowsDetail := {}
   ::nMaxRow := 0
   ::nMaxCol := 0
Return Self

METHOD RowDetail( nRow, nHeight, nStyle, lHide ) CLASS WorkSheetXLSX
   LOCAL nI
   IF hb_IsNumeric( nRow )
      IF Len( ::aRowsDetail ) < nRow
         FOR nI := Len( ::aRowsDetail ) + 1 TO nRow
            AAdd( ::aRowsDetail, { 0, 0, .F. } )
         NEXT
      ENDIF
      ::aRowsDetail[nRow] := { iif(hb_IsNil(nHeight),0,nHeight), iif(hb_IsNil(nStyle),0,nStyle), iif(hb_IsNil(lHide),.F.,lHide) }
   ENDIF
RETURN Self

METHOD Cell( uAddr, xValue, nStyle ) CLASS WorkSheetXLSX
   LOCAL nRow := 0, nCol := 0, nI
   
   IF ValType( uAddr ) == "A"
      nRow := uAddr[1]
      nCol := uAddr[2]
   ELSE
      XlsxCellRC( uAddr, @nRow, @nCol )
   ENDIF

   ::nMaxCol := iif( nCol > ::nMaxCol, nCol, ::nMaxCol )
   ::nMaxRow := iif( nRow > ::nMaxRow, nRow, ::nMaxRow )

   IF Len( ::aData ) < nRow
      FOR nI := Len( ::aData ) + 1 TO nRow 
         AAdd( ::aData, {} )
      NEXT
   ENDIF

   IF Len( ::aData[nRow] ) < nCol
      FOR nI := Len( ::aData[nRow] ) + 1 TO nCol
         AAdd( ::aData[nRow], NIL )
      NEXT
   ENDIF

   IF xValue != NIL
      ::aData[nRow, nCol] := xValue
   ENDIF
   
Return ::aData[nRow, nCol]


STATIC FUNCTION XlsxCellRC( cAddr, nRow, nCol )
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

STATIC FUNCTION ColIndexToLetter( nCol )
   LOCAL cLetter := ""
   LOCAL nTemp
   WHILE nCol > 0
      nTemp := ( nCol - 1 ) % 26
      cLetter := Chr( 65 + nTemp ) + cLetter
      nCol := Int( ( nCol - 1 ) / 26 )
   ENDWHILE
RETURN cLetter

STATIC FUNCTION FilePath( cFile )
   LOCAL nPos, cFilePath := iif( (nPos := RAt(hb_PS(), cFile)) != 0, SubStr(cFile, 1, nPos), "" )
RETURN cFilePath