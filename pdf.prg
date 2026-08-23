// +--------------------------------------------------------------------
// +
// +
// +
// +    Programa  : pdf.prg
// +
// +
// +
// +     Sistema:
// +
// +     Linguagem: Harbour
// +
// +     Autor: jcassiano
// +
// +     Copyright (c) 2024,  jcassiano
// +
// +
// +
// +
// +
// +    Documentado em 28-Dez-2024 as 10:42 am
// +
// +
// +
// +--------------------------------------------------------------------
// +

#include "harupdf.ch"
#include "hbcompat.ch"


// +--------------------------------------------------------------------
// +
// +
// +
// +    Function FILETOPDF()
// +
// +
// +
// +--------------------------------------------------------------------
// +
// +
// +


*+--------------------------------------------------------------------
*+    Function ParseLinhaFormatada()
*+    Quebra a linha com BBCode em blocos lógicos (Tokens)
*+--------------------------------------------------------------------
FUNCTION ParseLinhaFormatada( cLinha )
   LOCAL aTokens := {}
   LOCAL nPosIni, nPosFim, cTag
   
   WHILE !Empty( cLinha )
      nPosIni := At( "[", cLinha )
      
      IF nPosIni > 0
         // Extrai o texto antes da tag
         IF nPosIni > 1
            AAdd( aTokens, { "TEXT", SubStr( cLinha, 1, nPosIni - 1 ) } )
         ENDIF
         
         // Extrai a tag
         nPosFim := At( "]", cLinha, nPosIni )
         IF nPosFim > 0
            cTag := SubStr( cLinha, nPosIni + 1, nPosFim - nPosIni - 1 )
            AAdd( aTokens, { "CMD", Upper( cTag ) } )
            cLinha := SubStr( cLinha, nPosFim + 1 )
         ELSE
            AAdd( aTokens, { "TEXT", cLinha } ) 
            cLinha := ""
         ENDIF
      ELSE
         AAdd( aTokens, { "TEXT", cLinha } )
         cLinha := ""
      ENDIF
   ENDDO
   
   RETURN aTokens
   
  // +--------------------------------------------------------------------
// +
// +
// +
// +    Function FILETOPDF()
// +
// +
// +
// +--------------------------------------------------------------------
// +
// +
// +
FUNCTION FILETOPDF( cARQ, cFileToSave )

// **********************
   LOCAL nFileHandle
   LOCAL cLINHA
   LOCAL cAuthor, cCreator, cTitle, cSubject
   LOCAL aAMB
   
   // Variaveis de Controle de Fonte e Tokens
   LOCAL hFontNormal, hFontBold, hFontItalic, hFontBoldItalic
   LOCAL hCurrentFont, nCurrentSize
   LOCAL lBold := .F., lItalic := .F.
   LOCAL aTokens, i, cCmd, cVal, nPosIgual

   PRIVATE nLINES
   PRIVATE page, height, width, def_font, font
   PRIVATE pdf

   IF !hb_FileExists( cARQ )
      ALERTX( "Falta Arquivo " + cARQ )
      RETURN ""
   ENDIF

   cAuthor  := Space( 60 )
   cCreator := Space( 60 )
   cTitle   := Space( 60 )
   cSubject := Space( 60 )

   aAMB := SALVAA()
   CLSBOX( 19, 00, MaxRow(), MaxCol() )
   @ 20, 00 SAY "Autor:"
   @ 21, 00 SAY "Criador:"
   @ 22, 00 SAY "Titulo"
   @ 23, 00 SAY "Assunto:"
   @ 20, 15 GET cAuthor
   @ 21, 15 GET cCreator
   @ 22, 15 GET cTitle
   @ 23, 15 GET cSubject
   READ
   RESTAA( aAMB )

   IF ValType( cFileToSave ) # "C"
      cFileToSave := trocaext( cARQ, ".PDF" )   
   ENDIF

   nLINES      := FLineCount( cARQ )
   nFileHandle := hb_FOpen( cARQ )

   pdf := HPDF_New()

   IF pdf == NIL
      ALERTX( " Erro ao tentar gerar o Arquivo Pdf, Favor Tente novamente", "Aviso do Sistema" )
      RETURN "erro.txt"
   ENDIF

   // set compression mode 
   HPDF_SetCompressionMode( pdf, HPDF_COMP_ALL )
   HPDF_SetCurrentEncoder( PDF, "WinAnsiEncoding" )   

   IF !Empty( cAuthor )
      HPDF_SetInfoAttr( PDF, HPDF_INFO_AUTHOR, cAuthor )
   ENDIF
   IF !Empty( cCreator )
      HPDF_SetInfoAttr( PDF, HPDF_INFO_CREATOR, cCreator )
   ENDIF
   IF !Empty( cTitle )
      HPDF_SetInfoAttr( PDF, HPDF_INFO_TITLE, cTitle )
   ENDIF
   IF !Empty( cSubject )
      HPDF_SetInfoAttr( Pdf, HPDF_INFO_SUBJECT, cSubject )
   ENDIF
   HPDF_SetInfoDateAttr( PDF, HPDF_INFO_CREATION_DATE, { Year( Date() ), Month( Date() ), Day( Date() ), Val( SubStr( Time(), 1, 2 ) ), Val( SubStr( Time(), 4, 2 ) ), Val( SubStr( Time(), 7, 2 ) ), "+", 4, 0 } )

   page   := HPDF_AddPage( pdf )
   height := HPDF_Page_GetHeight( page )
   width  := HPDF_Page_GetWidth( page )

   // Inicializa as familias de fontes
   hFontNormal     := HPDF_GetFont( pdf, "Courier", "WinAnsiEncoding" )
   hFontBold       := HPDF_GetFont( pdf, "Courier-Bold", "WinAnsiEncoding" )
   hFontItalic     := HPDF_GetFont( pdf, "Courier-Oblique", "WinAnsiEncoding" )
   hFontBoldItalic := HPDF_GetFont( pdf, "Courier-BoldOblique", "WinAnsiEncoding" )
   
   // Define o estado inicial da pagina
   nCurrentSize := 7
   hCurrentFont := hFontNormal

   HPDF_Page_BeginText( page )
   HPDF_Page_MoveTextPos( page, 10, height - 10 )
   HPDF_Page_SetFontAndSize( page, hCurrentFont, nCurrentSize )

   vCONT := 0

   @ MaxRow(), 0 SAY "Gerando PDF"
   zei_fort( nLines,,, 0 )
   
   DO WHILE HB_FReadLine( nFileHandle, @cLinha ) == 0
      
      // 1. LIMPEZA E PADRONIZACAO
      cLinha := ParseEscapeToBBCode( cLinha )
      
      // Verifica o Salto de Pagina
      IF cLINHA = "##page##" .OR. cLINHA = "[PAGE]"
         vCONT := 79
      ELSE
         cLINHA := RANGEREM( Chr( 0 ), Chr( 09 ), cLINHA )   
         cLINHA := RANGEREM( Chr( 11 ), Chr( 12 ), cLINHA )  
         cLINHA := RANGEREM( Chr( 14 ), Chr( 31 ), cLINHA )  
         cLinha := hb_OEMToANSI( cLINHA )
         
         // 2. EXTRAI OS TOKENS DA LINHA FORMATADA
         aTokens := ParseLinhaFormatada( cLinha )
         
         // 3. IMPRIME TOKEN POR TOKEN NA MESMA LINHA
         FOR i := 1 TO Len( aTokens )
            IF aTokens[i, 1] == "CMD"
               cCmd := aTokens[i, 2]
               nPosIgual := At( "=", cCmd )
               
               IF nPosIgual > 0
                  cVal := SubStr( cCmd, nPosIgual + 1 )
                  cCmd := SubStr( cCmd, 1, nPosIgual - 1 )
               ENDIF
               
               DO CASE
                  CASE cCmd == "B"
                     lBold := .T.
                  CASE cCmd == "/B"
                     lBold := .F.
                  CASE cCmd == "I"
                     lItalic := .T.
                  CASE cCmd == "/I"
                     lItalic := .F.
                  CASE cCmd == "SIZE"
                     // O HaruPDF mapeia pixels reais. Adaptamos as fontes matriciais
                     IF cVal == "8"
                        nCurrentSize := 5
                     ELSEIF cVal == "12"
                        nCurrentSize := 7
                     ELSEIF cVal == "14"
                        nCurrentSize := 9
                     ELSE
                        nCurrentSize := Val( cVal )
                     ENDIF
                  CASE cCmd == "/SIZE"
                     nCurrentSize := 7
               ENDCASE
               
               // Seleciona a fonte correta com base no Negrito e Italico
               IF lBold .AND. lItalic
                  hCurrentFont := hFontBoldItalic
               ELSEIF lBold
                  hCurrentFont := hFontBold
               ELSEIF lItalic
                  hCurrentFont := hFontItalic
               ELSE
                  hCurrentFont := hFontNormal
               ENDIF
               
               // Aplica a nova configuracao
               HPDF_Page_SetFontAndSize( page, hCurrentFont, nCurrentSize )
               
            ELSEIF aTokens[i, 1] == "TEXT"
               // Imprime a fracao do texto. O HaruPDF empurra o X para frente automaticamente!
               HPDF_Page_ShowText( page, aTokens[i, 2] )
            ENDIF
         NEXT

         // 4. DESCE PARA A PROXIMA LINHA EIXO Y (-10)
         HPDF_Page_MoveTextPos( page, 0, - 10 )
      ENDIF
      
      vCONT := vCONT + 1
      
      // 5. NOVA PAGINA
      IF vCONT >= 80
         HPDF_Page_EndText( page ) // Fecha objeto texto atual
         page := HPDF_AddPage( pdf )
         HPDF_Page_SetLineWidth( page, 1 )
         HPDF_Page_BeginText( page )
         HPDF_Page_MoveTextPos( page, 10, height - 10 )
         
         // Repassa a fonte e tamanho atuais para a nova pagina recem-criada
         HPDF_Page_SetFontAndSize( page, hCurrentFont, nCurrentSize )
         vCONT := 0
      ENDIF
      
      zei_fort( nLINES,,, 1 )
   ENDDO

   HPDF_Page_EndText( page )
   HPDF_SaveToFile( pdf, cFileToSave )

   HPDF_Free( pdf )
   FClose( nFileHandle )
   @ MaxRow(), 0 SAY "Gerado PDF " + cFILETOSAVE

   RETURN cFileToSave 