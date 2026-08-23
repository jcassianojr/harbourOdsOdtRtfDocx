


////#INCLUDE "COMANDO.CH"
#INCLUDE "TRY.CH"
#INCLUDE "BOX.CH"




*+--------------------------------------------------------------------
*+
*+
*+
*+    Function filetohtml()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function filetohtml(cFILE)

RETURN fileconvert(cFILE,"HTML")



*+--------------------------------------------------------------------
*+
*+
*+
*+    Function filetoRTF()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function filetoRTF(cFILE)

RETURN fileconvert(cFILE,"RTF")



*+--------------------------------------------------------------------
*+
*+
*+
*+    Function filetoTXTWin()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function filetoTXTWin(cFILE)

RETURN fileconvert(cFILE,"TXTWIN")



*+--------------------------------------------------------------------
*+
*+
*+
*+    Function fileconvert()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function fileconvert(cFILE,cTIPO)

local x
nHANDLE := hb_fopen(cFILE)
if nHANDLE = 0
   ALERTX("Arquivo nao Pode ser Aberto")
endif
cFILE := substr(cFILE,1,at(".",cFILE) - 1)
if cTIPO = "HTML"
   cFILE += ".HTM"
endif
if cTIPO = "RTF"
   cFILE += ".RTF"
endif
if cTIPO = "TXTWIN"
   cFILE += ".TXT"
endif
nHANWRI := fcreate(cFILE,0)
if nHANWRI = - 1
   ALERTX("Arquivo nao Pode ser Criado"+cFILE)
   return "erro.txt"
endif
if cTIPO = "HTML"
   fwrite(nHANWRI,"<html>"+chr(13)+chr(10))
   fwrite(nHANWRI,"<head>"+chr(13)+chr(10))
   fwrite(nHANWRI,'<meta http-equiv="Content-Type"'+chr(13)+chr(10))
   fwrite(nHANWRI,'content="text/html; charset=iso-8859-1">'+chr(13)+chr(10))
   fwrite(nHANWRI,'<meta name="GENERATOR" content="Sistemas">'+chr(13)+chr(10))
   fwrite(nHANWRI,"<title>Titulo</title>"+chr(13)+chr(10))
   fwrite(nHANWRI,"</head>"+chr(13)+chr(10))
   fwrite(nHANWRI,"<body>"+chr(13)+chr(10))
endif
if cTIPO = "RTF"
   fwrite(nHANWRI,"{\rtf1\ansi\ansicpg850\deff5{\fonttbl{\f0\fmodern\fprq1  Courier New;}{\f1\fnil\fcharset254 Times New Roman;}{\f2\fswiss\fprq2\fcharset254 Verdana;}{\f3\fnil\fcharset2 Symbol;}{\f4\fmodern\fprq1\fcharset254 Draft 10cpi;}{\f5\fmodern\fprq1\fcharset254 Draft 12cpi;}{\f6\fnil\fprq1\fcharset0 ProFontWindows;}{\f7\fmodern\fprq1\fcharset0 FixedDB ThaiText;} }")
   fwrite(nHANWRI,"{\colortbl ;\red0\green0\blue255;\red255\green0\blue0;\red0\green255\blue0;\red0\green0\blue0;\red128\green128\blue128;\red192\green192\blue192;\red255\green255\blue0;}")
   fwrite(nHANWRI,"\viewkind1\viewscale100\uc1\pard\lang1046")
   fwrite(nHANWRI,"\fafixed")
   fwrite(nHANWRI,"\margl283\margr283\margt1134\margb567")  //margens
   fwrite(nHANWRI,"\f0\fs20")   //inicia com fonte 0(Courier New) Tabmanho 20 20
endif
cVAR := FREADLINE(nHANDLE)

while cVAR <> "__FINAL__"
   cVAR:= ParseEscapeToBBCode( cVAR )
   if CTIPO = "RTF"   //trata caraceter antes converter ansi
      // 1. Mantemos APENAS a tabela de acentuacao e caracteres especiais:
      aacentos := {{" ","\'e1"},{"µ","\'c1"},{"µ","\'e1"},{"‚","\'e9"},{" ","\'c9"},{"¡","\'ed"},{"Ö","\'cd"},{"¢","\'f3"},;
       {"à","\'d3"},{"£","\'fa"},{"é","\'da"},{"‡","\'e7"},{"€","\'c7"},{"…","\'e0"},{"·","\'c0"},{"ƒ","\'e2"},;
       {"“","\'f4"},{"â","\'d4"},{"Æ","\'e3"},{"Ç","\'c3"},{"ä","\'f5"},{"å","\'d5"},{"Ò","\'ca"},{"ˆ","\'ea"},;
       {"Ô","\'c8"},{"¥","\'d1"},{"¤","\'f1"},{"¦","\'aa"},{"§","\'ba"},{"Þ","\'cc"},{"×","\'ce"},{"ã","\'d2"},;
       {"ë","\'d9"},{"~",Chr(13)},{"ý","\super 2 \nosupersub"},{"ü","\super 3 \nosupersub"},;
       {"ê","\'db"}}

      // 2. Mantemos as pseudo-tags velhas (+b, -b, etc) caso algum relatorio antigo as use literalmente no texto:
      AADD(aacentos,{"+b","\b "})
      AADD(aacentos,{"-b","\b0 "})
      AADD(aacentos,{"+u","\ul "})
      AADD(aacentos,{"-u","\ulnone "})
      AADD(aacentos,{"+i","\i "})
      AADD(aacentos,{"-i","\i0 "})
      
      // 3. O NOVO MAPEMENTO BBCODE -> RTF (Substitui todos os CHR e cIMPNEG antigos)
      AADD(aacentos,{"[B]","\b "})         // Negrito ON
      AADD(aacentos,{"[/B]","\b0 "})       // Negrito OFF
      AADD(aacentos,{"[I]","\i "})         // Italico ON
      AADD(aacentos,{"[/I]","\i0 "})       // Italico OFF
      AADD(aacentos,{"[U]","\ul "})        // Sublinhado ON
      AADD(aacentos,{"[/U]","\ulnone "})   // Sublinhado OFF
      AADD(aacentos,{"[PAGE]"," \sect\sectd "})  // Salto folha

      // No RTF, o tamanho da fonte eh definido em MEIOS pontos (ex: \fs24 = 12pt)
      AADD(aacentos,{"[SIZE=8]","\fs16 "}) 
      AADD(aacentos,{"[SIZE=12]","\fs24 "})
      AADD(aacentos,{"[SIZE=14]","\fs28 "})

      // Executa as substituicoes na linha
      for x := 1 to len(aacentos)
         cVAR := STRTRAN(cVAR,aacentos[x,1],aacentos[x,2])
      next x
   endif
   cVAR := Convansi(cVAR)   //Converte Window
   //Remove caracteres inferioes a espaco chr32() mantendo line feed
   cVAR := RANGEREM(chr(0),chr(09),cVAR)  // CHR(13)+CHR(10) Line Feed Manter
   cVAR := RANGEREM(chr(11),chr(12),cVAR)
   cVAR := RANGEREM(chr(14),chr(31),cVAR)
   if cTIPO = "HTML"
      // 1. Trata os atalhos exclusivos que existiam na matriz do RTF
      cVAR := StrTran( cVAR, "~", "<br>" )
      cVAR := StrTran( cVAR, "ý", "<sup>2</sup>" )
      cVAR := StrTran( cVAR, "ü", "<sup>3</sup>" )
      
      // 2. Trata as pseudo-tags antigas (caso ainda venham no texto)
      cVAR := StrTran( cVAR, "+b", "[B]" )
      cVAR := StrTran( cVAR, "-b", "[/B]" )
      cVAR := StrTran( cVAR, "+i", "[I]" )
      cVAR := StrTran( cVAR, "-i", "[/I]" )
      cVAR := StrTran( cVAR, "+u", "[U]" )
      cVAR := StrTran( cVAR, "-u", "[/U]" )
   
      cVAR := str2html(cVAR)
      cVAR := ParseBBCodeToHTML(cVAR)
      cVAR += chr(13)+chr(10)+"<BR>"
   endif
   if CTIPO = "RTF"
      cVAR += "\par"+chr(13)
   endif
   if cTIPO = "TXTWIN"
      cVAR += chr(13)+chr(10)
   endif
   fwrite(nHANWRI,cvAR)
   mds(cVAR)
   cVAR := FREADLINE(nHANDLE)
enddo
if cTIPO = "HTML"
   fwrite(nHANWRI,"</body>"+chr(13)+chr(10)+"</html>"+chr(13)+chr(10))
endif
if cTIPO = "RTF"
   fwrite(nHANWRI,"\par}")
endif
fclose(nHANDLE)
fclose(nHANWRI)
return cFILE

*+--------------------------------------------------------------------
*+    Function printtodocx()
*+--------------------------------------------------------------------
function printtodocx( cARQ, cFileToSave )
   LOCAL cLinha, nFileHandle
   LOCAL oDoc

   IF !hb_FileExists( cARQ )
      ALERTX( "Falta Arquivo " + cARQ )
      RETURN ""
   ENDIF

   IF ValType( cFileToSave ) # "C"
      cFileToSave := trocaext( cARQ, ".DOCX" )
   ENDIF

   oDoc := DocumentDOCX():New( cFileToSave )
   oDoc:AddParagraph( "Relatório do Sistema" )

   nFileHandle := hb_FOpen( cARQ )
   
   DO WHILE HB_FReadLine( nFileHandle, @cLinha ) == 0
      cLinha := ParseEscapeToBBCode( cLinha ) 
      IF cLinha == "##page##"
         // Salto de página compatível com o DOCX que configuramos na classe
         oDoc:AddParagraph( "[PAGE]" )
      ELSE
         cLinha := RANGEREM( Chr( 0 ), Chr( 09 ), cLinha )
         cLinha := RANGEREM( Chr( 11 ), Chr( 12 ), cLinha )
         cLinha := RANGEREM( Chr( 14 ), Chr( 31 ), cLinha )
         cLinha := hb_OEMToANSI( cLinha )
         
         oDoc:AddParagraph( cLinha )
      ENDIF
   ENDDO

   FClose( nFileHandle )
   oDoc:Save()
   
   @ MaxRow(), 0 SAY "Gerado DOCX " + cFileToSave
RETURN cFileToSave

*+--------------------------------------------------------------------
*+    Function printtoodt()
*+--------------------------------------------------------------------
function printtoodt( cARQ, cFileToSave )
   LOCAL cLinha, nFileHandle
   LOCAL oDoc

   IF !hb_FileExists( cARQ )
      ALERTX( "Falta Arquivo " + cARQ )
      RETURN ""
   ENDIF

   IF ValType( cFileToSave ) # "C"
      cFileToSave := trocaext( cARQ, ".ODT" )
   ENDIF

   oDoc := DocumentODT():New( cFileToSave )
   oDoc:AddHeading( "Relatório do Sistema", 1 )

   nFileHandle := hb_FOpen( cARQ )
   zei_fort( FLineCount( cARQ ),,, 0 )
   
   DO WHILE HB_FReadLine( nFileHandle, @cLinha ) == 0
      cLinha := ParseEscapeToBBCode( cLinha ) 
      IF cLinha == "##page##"
         // Salto de página opcional ou separador no ODT
         oDoc:AddParagraph( "----------------------------------------" )
      ELSE
         cLinha := RANGEREM( Chr( 0 ), Chr( 09 ), cLinha )
         cLinha := RANGEREM( Chr( 11 ), Chr( 12 ), cLinha )
         cLinha := RANGEREM( Chr( 14 ), Chr( 31 ), cLinha )
         cLinha := hb_OEMToANSI( cLinha )
         
         oDoc:AddParagraph( cLinha )
      ENDIF
      zei_fort(,, 1 )
   ENDDO

   FClose( nFileHandle )
   oDoc:Save()
   
   @ MaxRow(), 0 SAY "Gerado ODT " + cFileToSave
RETURN cFileToSave


*+--------------------------------------------------------------------
*+
*+    Function filezebrapdf()
*+
*+--------------------------------------------------------------------
FUNCTION filezebrapdf( cARQSPO )
   
    Local oConverter
   Local cPdfFile 
   Local lSuccess
   
   cPdfFile:=HB_FNAMEEXTSET(cARQSPO,"pdf")
   
    oConverter := TZebraToPdf():New()
   
   // Lemos do arquivo que acabamos de criar
   lSuccess := oConverter:Generate( hb_MemoRead( cARQSPO ), cPdfFile )


RETURN cFILE


*+--------------------------------------------------------------------
*+    Function ParseBBCodeToHTML()
*+    Converte tags de [BBCode] para <HTML>
*+--------------------------------------------------------------------
FUNCTION ParseBBCodeToHTML( cLinha )
   LOCAL cResultado := cLinha
   LOCAL nPosIni, nPosFim, cTag, cComando, cValor, nPosIgual
   
   // 1. Substituicoes Diretas (Estilos e Estrutura)
   cResultado := StrTran( cResultado, "[B]", "<b>" )
   cResultado := StrTran( cResultado, "[/B]", "</b>" )
   cResultado := StrTran( cResultado, "[I]", "<i>" )
   cResultado := StrTran( cResultado, "[/I]", "</i>" )
   cResultado := StrTran( cResultado, "[U]", "<u>" )
   cResultado := StrTran( cResultado, "[/U]", "</u>" )
   cResultado := StrTran( cResultado, "[S]", "<s>" )
   cResultado := StrTran( cResultado, "[/S]", "</s>" )
   
   cResultado := StrTran( cResultado, "[CENTER]", "<center>" )
   cResultado := StrTran( cResultado, "[/CENTER]", "</center>" )
   cResultado := StrTran( cResultado, "[HR]", "<hr>" )
   
   // Traduz a quebra de pagina do BBCode para CSS embutido no HTML
   cResultado := StrTran( cResultado, "[PAGE]", '<div style="page-break-after: always;"></div>' )

   // Traduz o antigo ##page## caso ainda venha de relatorios velhos
   cResultado := StrTran( cResultado, "##page##", '<div style="page-break-after: always;"></div>' )

   // 2. Parser para tags com parametros (Ex: [COLOR=red] ou [FONT=Arial])
   nPosIni := At( "[", cResultado )
   
   WHILE nPosIni > 0
      nPosFim := At( "]", cResultado, nPosIni )
      
      IF nPosFim > 0
         cTag := SubStr( cResultado, nPosIni + 1, nPosFim - nPosIni - 1 )
         nPosIgual := At( "=", cTag )
         
         IF nPosIgual > 0
            cComando := Upper( SubStr( cTag, 1, nPosIgual - 1 ) )
            cValor   := SubStr( cTag, nPosIgual + 1 )
            
            DO CASE
               CASE cComando == "COLOR"
                  cResultado := Left( cResultado, nPosIni - 1 ) + '<font color="' + cValor + '">' + SubStr( cResultado, nPosFim + 1 )
               CASE cComando == "SIZE"
                  cResultado := Left( cResultado, nPosIni - 1 ) + '<font size="' + cValor + '">' + SubStr( cResultado, nPosFim + 1 )
               CASE cComando == "FONT"
                  cResultado := Left( cResultado, nPosIni - 1 ) + '<font face="' + cValor + '">' + SubStr( cResultado, nPosFim + 1 )
            ENDCASE
         ENDIF
      ENDIF
      
      nPosIni := At( "[", cResultado, nPosIni + 1 )
   ENDDO
   
   // 3. Fechamento das tags que usavam parametros
   cResultado := StrTran( cResultado, "[/COLOR]", "</font>" )
   cResultado := StrTran( cResultado, "[/SIZE]", "</font>" )
   cResultado := StrTran( cResultado, "[/FONT]", "</font>" )

RETURN cResultado


*+--------------------------------------------------------------------
*+    Function ParseEscapeToBBCode()
*+    Traduz comandos binarios de impressora para tags [BBCode]
*+--------------------------------------------------------------------
FUNCTION ParseEscapeToBBCode( cLinha )

   // 1. Substitui as variaveis globais configuradas (Caso o sistema passe as macros direto)
   IF Type("cIMPNEG") == "C" .AND. !Empty(cIMPNEG)
      cLinha := StrTran( cLinha, cIMPNEG, "[B]" )
   ENDIF
   IF Type("cIMPNER") == "C" .AND. !Empty(cIMPNER)
      cLinha := StrTran( cLinha, cIMPNER, "[/B]" )
   ENDIF
   IF Type("ciMPNER") == "C" .AND. !Empty(ciMPNER) 
      cLinha := StrTran( cLinha, ciMPNER, "[/B]" )
   ENDIF
   IF Type("cIMPCOM") == "C" .AND. !Empty(cIMPCOM)
      cLinha := StrTran( cLinha, cIMPCOM, "[SIZE=8]" ) 
   ENDIF
   IF Type("cIMPEXP") == "C" .AND. !Empty(cIMPEXP)
      cLinha := StrTran( cLinha, cIMPEXP, "[SIZE=14]" ) 
   ENDIF

   // ====================================================================
   // 2. COMANDOS HARDCODED: EPSON / MATRICIAIS PADRAO
   // ====================================================================
   cLinha := StrTran( cLinha, Chr(27) + Chr(69), "[B]" )            // Negrito ON
   cLinha := StrTran( cLinha, Chr(27) + Chr(70), "[/B]" )           // Negrito OFF
   cLinha := StrTran( cLinha, Chr(27) + Chr(45) + Chr(00), "[U]" )  // Sublinhado ON
   cLinha := StrTran( cLinha, Chr(27) + Chr(45) + Chr(01), "[/U]" ) // Sublinhado OFF
   cLinha := StrTran( cLinha, Chr(27) + Chr(52), "[I]" )            // Italico ON
   cLinha := StrTran( cLinha, Chr(27) + Chr(53), "[/I]" )           // Italico OFF
   
   cLinha := StrTran( cLinha, Chr(14) + Chr(15), "[SIZE=12][B]" ) 
   cLinha := StrTran( cLinha, Chr(15), "[SIZE=8]" )                 // Comprimido ON
   cLinha := StrTran( cLinha, Chr(18), "[SIZE=12]" )                // Comprimido OFF (Volta Normal)
   cLinha := StrTran( cLinha, Chr(14), "[SIZE=14]" )                // Expandido ON
   cLinha := StrTran( cLinha, Chr(20), "[SIZE=12]" )                // Expandido OFF

   // ====================================================================
   // 3. COMANDOS HARDCODED: HP DESKJET
   // ====================================================================
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+"16"+chr(72), "[SIZE=12]" ) // Normal
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+"12"+chr(72), "[SIZE=8]" )  // Comprimido
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+"23"+chr(72), "[SIZE=14]" ) // Expandido
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+CHR(51)+chr(66), "[B]" )    // Negrito ON (Deskjet e Laser)
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+CHR(45)+CHR(51)+chr(66), "[/B]" ) // Negrito OFF

   // ====================================================================
   // 4. COMANDOS HARDCODED: HP LASER
   // ====================================================================
   cLinha := StrTran( cLinha, chr(27)+chr(38)+chr(107)+chr(50)+chr(83), "[SIZE=12]" ) // Normal
   cLinha := StrTran( cLinha, chr(27)+chr(38)+chr(107)+chr(48)+chr(83), "[SIZE=8]" )  // Comprimido
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+CHR(48)+chr(66), "[/B]" )      // Negrito OFF

   // ====================================================================
   // 5. COMANDOS HARDCODED: LEXMARK
   // ====================================================================
   // Normal
   cLinha := StrTran( cLinha, chr(27)+chr(38)+chr(107)+chr(50)+chr(83)+chr(27)+chr(38)+chr(108)+"8"+chr(68)+chr(27)+chr(38)+chr(108)+"90"+chr(80), "[SIZE=12]" )
   // Comprimido
   cLinha := StrTran( cLinha, chr(27)+chr(38)+chr(107)+chr(52)+chr(83)+chr(27)+chr(38)+chr(108)+"5"+chr(68)+chr(27)+chr(38)+chr(108)+"66"+chr(80), "[SIZE=8]" )
   // Expandido
   cLinha := StrTran( cLinha, chr(27)+chr(40)+chr(115)+"23"+chr(72)+chr(27)+chr(38)+chr(108)+"10"+chr(68)+chr(27)+chr(38)+chr(108)+"90"+chr(80), "[SIZE=14]" )

   // ====================================================================
   // 6. ESTRUTURA GERAL
   // ====================================================================
   // Salto de Pagina (Form Feed)
   cLinha := StrTran( cLinha, Chr(12), "[PAGE]" )              

RETURN cLinha