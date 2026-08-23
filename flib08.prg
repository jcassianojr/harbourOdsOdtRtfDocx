*+--------------------------------------------------------------------
*+
*+
*+
*+    Programa  : flib08.prg
*+
*+
*+
*+     Sistema:
*+
*+     Linguagem: Harbour
*+
*+     Autor: jcassiano
*+
*+     Copyright (c) 2024,  jcassiano
*+
*+     
*+
*+
*+
*+    Documentado em 28-Dez-2024 as 10:42 am
*+
*+
*+
*+--------------------------------------------------------------------
*+




////#INCLUDE "COMANDO.CH"
#INCLUDE "TRY.CH"
#INCLUDE "BOX.CH"



*+--------------------------------------------------------------------
*+
*+
*+
*+    Function CHECKIMP()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function CHECKIMP(nTIP,lIMPHP,lZEBRA)


local RETORNO    := .F.
local cTELA
local nPORTA
LOCAL QuePrinter
local nERRO
local cERRO
local cCAMINHO
local aRETU
lIMPEMAIL := .F.



priv aMENUPROMPTS := {}
if valtype(lIMPHP) # "L"
   lIMPHP := .F.
endif
if valtype(lZEBRA) # "L"
   lZEBRA := .F.
endif
set print to
if valtype(nTIP) # "N"
   nTIPSPO := 2   //LPT1
else
   nTIPSPO := nTIP
endif
if nTIPSPO = 0
   cTELA := savescreen(6,0,17,80)
   CLSBOX(6,0,17,80)
   HB_dispbox(6,0,17,79,B_DOUBLE+" ")
   while .T.
      oPCAO(07,01," &Video                           ",86)  //1
      oPCAO(08,01," LPT&1 Impressora                 ",49)  //2
      oPCAO(09,01," LPT&2 Impressora                 ",50)  //3
      oPCAO(10,01," LPT&3 Impressora                 ",51)  //4
      oPCAO(11,01," Impressora Windows &WINPRN       ",84)  //5
      oPCAO(12,01," &TXT Arquivo Texto Dos(OEM)      ",84)  //6
      oPCAO(13,01," TXT Arquivo Texto Windows(&Ansi) ",65)  //7
      OPCAO(14,01," &HTML                            ",72)  //8
      oPCAO(07,41," &RTF(Rith Text Format)           ",82)  //9
      oPCAO(08,41," &PDF(Portable Document Format)   ",80)  //10
      oPCAO(09,41," &ODT(OpenDocument Text)          ",87)  //11 
      oPCAO(10,41," Impressora w&Indows RAW          ",73)  //12
      oPCAO(11,41," C&OM1                            ",79)  //13
      oPCAO(12,41," CO&M2                            ",77)  //14
      oPCAO(13,41,"                                  ",)  //15 //oPCAO( 13, 41, " &Email                           ", 69 )  //15
      oPCAO(14,41," Re&dicionar Portas               ",68)  //16
      IF lZEBRA
         oPCAO(15,41," Preview &Zebra pdf                ",90)  //17
      ENDIF
      nTIPSPO := menu(,0)
      if nTIPSPO = 15
         ALERTX("Opcao Desativada")
         loop
      endif
      if nTIPSPO = 16
         nPORTA   := 1
         cCAMINHO := "\\server\printer"+space(30)
         MDS("Porta LPT(123) Caminho \\server\printer")
         @ 24,45 get nPORTA   pict "9"    valid nPORTA > 0 .and. nPORTA < 4       
         @ 24,48 get cCAMINHO pict "@S30"                                         
         if READCUR()
            if NETREDIR("LPT"+strzero(nPORTA,1)+":",cCAMINHO)
               ALERTX("Redericionamento OK")
            else
               ALERTX("Erro ao Direcionar")
            endif
         endif
         MDS("")
      else
         exit
      endif
   enddo
   restscreen(6,0,17,80,cTELA)
endif
if nTIPSPO < 1 .or. nTIPSPO > if(zebra,17,16)
   retu .F.
endif
nPORTA     := 0
QuePrinter := ""
if nTIPSPO = 2
   set print to LPT1
   nPORTA     := 1
   QuePrinter := "LPT1:"
endif
if nTIPSPO = 3
   set print to LPT2
   nPORTA     := 2
   QuePrinter := "LPT2:"
endif
if nTIPSPO = 4
   set print to LPT3
   QuePrinter := "LPT3:"
   nPORTA     := 3
endif
if nTIPSPO = 13
   set print to COM1
   QuePrinter := "COM1:"
endif
if nTIPSPO = 14
   set print to COM2
   QuePrinter := "COM2:"
endif
if nTIPSPO = 2 .or. nTIPSPO = 3 .or. nTIPSPO = 4
   if lIMPHP
      aRETU := IMPHP()
   endif
   while .T.
      if mdg("Impressora Esta Pronta")
         //         IF IF(nPORTA=1,ISPRINTER(),PRINTREADY(nPORTA))
         if PRINTREADY(nPORTA)
            RETORNO := .T.
            exit
         else
            cERRO := "Impressora Ligada, Cabo Desconectado, Verifique"
            nERRO := PRINTSTAT(nPORTA)
            do case
            case nERRO = 1
               cERRO := "Erro Tempo de Coneccao"
            case nERRO = 4
               cERRO := "Erro de Transmissao"
            case nERRO = 5
               cERRO := "Nao Esta Online(Em Linha)"
            case nERRO = 6
               cERRO := "Sem Papel"
            case nERRO = 8
               cERRO := "Nao Disponivel"
            endcase


            //IsImpressora( QuePrinter )
            //prnstatus( QuePrinter)
            ALERTX(cERRO)
            if !MDG("Continuar Assim Mesmo")
               loop
            else
               RETORNO := .T.
               exit
            endif
         endif
      else
         set print to
         exit
      endif
   enddo
endif
if (nTIPSPO > 5 .and. nTIPSPO < 12) .OR. nTIPSPO = 17   //TXT OEM TXT ANSI HTML RTF PDF ZEBRA_17
   //cARQSPO := "c:\temp\nome000" + space( 20 )
   //cARQUIVO=WIN_GETSAVEFILENAME(        , "Exportar", HB_CWD(),"txt"   , "*.txt" , 1            ,               , cARQUIVO)
   cARQSPO := STRTRAN(TMPFILE("TXT"),".TXT","")+SPACE(30)   //"c:\temp\nome000" + space( 20 )
   MDS("Digite o Nome do Arquivo ")
   @ 24,30 get cARQSPO valid !empty(cARQSPO)        
   RETORNO := READCUR()
   cARQSPO := strtran(cARQSPO," ","")
   if empty(cARQSPO)
      RETORNO := .F.
   else
      if nTIPSPO = 7
         cARQSPO += ".TXW"  //A Funcoes trocam a extencao para txt
         //Evita criar com o mesmo nome
      else
         cARQSPO += ".TXT"  //A Funcoes trocam a extencao para pdf/htm/rtf/odt
      endif
      FERASE(cARQSPO)
      set print to &cARQSPO
   endif
endif
if nTIPSPO = 1 .or. nTIPSPO = 12 .or. nTIPSPO = 5   //Video  //winraw //win32prn
   cARQSPO := tmpfile("TXT")
   RETORNO := .T.
   FERASE(cARQSPO)
   set print to &cARQSPO
endif
return RETORNO


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function IMPEND()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function IMPEND(lAPAGA)

LOCAL cTELA
LOCAL nOPCAO
IF VALTYPE(lAPAGA) # "L"
   lAPAGA := .T.
ENDIF
VIDEO()
set print to
if nTIPSPO = 1  //Video
   VERTXT(cARQSPO)
endif
if nTIPSPO = 6  //txt oem
   cFILE := cARQSPO
endif
if nTIPSPO = 7  //txt Win
   cFILE := FILETOtxtwin(cARQSPO)
endif
if nTIPSPO = 8  //html
   cFILE := FILETOHTML(cARQSPO)
endif
if nTIPSPO = 9  //rtf
   cFILE := FILETOrtf(cARQSPO)
endif
if nTIPSPO = 10   //pdf
   cTELA := savescreen(6,0,17,80)
   CLSBOX(6,0,17,80)
   HB_dispbox(6,0,17,79,B_DOUBLE+" ")
   oPCAO(07,01," &Interno   ",73)   //1
   oPCAO(08,01," &PDFCreator",80)   //2
   oPCAO(09,01," &MS PDF    ",77)   //3
   oPCAO(10,01," &Retornar  ",82)   //4
   nOPCAO := menu(,0)
   restscreen(6,0,17,80,cTELA)
   DO CASE
   CASE nOPCAO = 1
      cFILE := filetopdf(cARQSPO)
   CASE nOPCAO = 2
      PrintUSB(cARQSPO,"PDFCreator")
      nTIPSPO := - 1  //-1 para nao processar mais nada		
   CASE nOPCAO = 3
      PrintUSB(cARQSPO,"Microsoft Print To PDF")
      nTIPSPO := - 1  //-1 para nao processar mais nada	
   CASE nOPCAO = 4
      nTIPSPO := - 1  //-1 para nao processar mais nada	
   ENDCASE
endif

if nTIPSPO = 11    
   cFILE := printtoodt(cARQSPO) //odt
endif
if nTIPSPO = 12   //print raw
   FILEtoprwin(cARQSPO,1)
endif
if nTIPSPO = 5  //win32prn
   FILEtoprwin(cARQSPO,2)
endif
if lAPAGA .AND. (nTIPSPO = 1 .or. nTIPSPO = 7 .or. nTIPSPO = 8 .or. nTIPSPO = 9 .or. nTIPSPO = 10 ;
           .or. nTIPSPO = 11 .or. nTIPSPO = 12 .or. nTIPSPO = 5)
   //6 txt nao muda extensao nao apagar
   ferase(cARQSPO)  
   //demais direto na porta
endif
if nTIPSPO = 17
   cFILE := filezebrapdf(cARQSPO)
endif

if nTIPSPO = 6 .or. nTIPSPO = 7 .or. nTIPSPO = 8 .or. nTIPSPO = 9 .or. nTIPSPO = 10 .or. nTIPSPO = 17
   cTELA := savescreen(6,0,17,80)
   CLSBOX(6,0,17,80)
   HB_dispbox(6,0,17,79,B_DOUBLE+" ")
   oPCAO(07,01," &Imprimir  ",73)   //1
   oPCAO(08,01," &Abrir     ",65)   //2
   oPCAO(09,01," &Email     ",69)   //3
   oPCAO(10,01," &Retornar  ",82)   //4
   nOPCAO := menu(,0)
   restscreen(6,0,17,80,cTELA)
   DO CASE
   CASE nOPCAO = 1
      shellexecprint(cFILE)
   CASE nOPCAO = 2
      //wapi_ShellExecute(0,"open",cFILE,"",0,1)
      //ShellExecuteOpen( cFileName, cParameters, cPath, nShow )
      ShellExecuteOpen( cFILE, "", "",1 )
   CASE nOPCAO = 3
      filetoemail(cFILE)
   CASE nOPCAO = 4
      nTIPSPO := - 1  //-1 para nao processar mais nada	
   ENDCASE
endif
cIMPORI   := ""
lIMPEMAIL := .F.
return .T.


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function IMPSTR()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function IMPSTR(cVAR)   //Passada String

if type("nTIPSPO") = "U" .OR. nTIPSPO = 2 .or. nTIPSPO = 3 ;
                 .or. nTIPSPO = 4 .OR. nTIPSPO = 13 .OR. nTIPSPO = 14 .OR. nTIPSPO = 5  //lpt123 com12 winprn
else
   return ""
endif
retu cVAR


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function IMPCHR()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function IMPCHR(cCAR)   //Passada codigo ascii

if type("nTIPSPO") = "U" .OR. nTIPSPO = 2 .or. nTIPSPO = 3 ;
                 .or. nTIPSPO = 4 .OR. nTIPSPO = 13 ;
                 .OR. nTIPSPO = 14 .OR. nTIPSPO = 5   //lpt123 com12 winusb/troca tamanho letra
else
   retu ""
endif
if valtype(cCAR) # "N"
   retu IMPSTR(cCAR)  //Caso Chamada string inves do codigo ascii
endif
return chr(cCAR)


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function IMPFOL()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function IMPFOL(cCAR)

DO CASE
CASE type("nTIPSPO") = "U"  //nao faz nada
case nTIPSPO = 2 .or. nTIPSPO = 3 .or. nTIPSPO = 4 .OR. nTIPSPO = 13 .or. nTIPSPO = 14  //lpt123 com12
   eject
case nTIPSPO = 9  //rtf
   @ prow(),pcol() say " \sect\sectd"         
case nTIPSPO = 10   //pdf
   @ prow(),pcol() say "##page##"         
case nTIPSPO = 5  //WINPRN
   @ prow(),pcol() say "\\page\\"         
otherwise
   @ prow(),pcol() say chr(13)+chr(10)         
endcase
retu


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function IMPHP()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
function IMPHP()


local nHP
local aRETU
aRETU := {chr(15),chr(18),chr(14),CHR(27)+CHR(69),CHR(27)+CHR(70)}
//1-normal 2-comprimido 3-expandido 4-negrito 5-sem negrito
cTELA := savescreen(6,26,16,58)
CLSBOX(6,26,16,58)
HB_dispbox(6,26,16,58,B_DOUBLE+" ")
oPCAO(8,28," &Matricial/Epson  ",77)
oPCAO(9,28," &HP Deskjet       ",72)
oPCAO(10,28," &Laser            ",76)
opcao(11,28," Le&Xmark          ",88)
opcao(12,28," Escolher Lista  &1",49)
opcao(13,28," Escolher Lista  &2",50)
opcao(14,28," Escolher Lista  &3",51)
oPCAO(15,28," &Nenhum Codigo    ",78)
nHP := menu(3,0)
restscreen(6,26,16,58,cTELA)


if nHP = 2  //HP
   aRETU := {chr(27)+chr(40)+chr(115)+"16"+chr(72),;
    chr(27)+chr(40)+chr(115)+"12"+chr(72),;
    chr(27)+chr(40)+chr(115)+"23"+chr(72),;
    chr(27)+chr(40)+chr(115)+CHR(51)+chr(66),;
    chr(27)+chr(40)+chr(115)+CHR(45)+CHR(51)+chr(66)}
endif
if nHP = 3  //LASER
   aRETU := {chr(27)+chr(38)+chr(107)+chr(50)+chr(83),;
    chr(27)+chr(38)+chr(107)+chr(48)+chr(83),"",;
    chr(27)+chr(40)+chr(115)+CHR(51)+chr(66),;
    chr(27)+chr(40)+chr(115)+CHR(48)+chr(66)}
endif
if nHP = 4  //LEXMARK
   aRETU := {chr(27)+chr(38)+chr(107)+chr(50)+chr(83)+chr(27)+chr(38)+;
    chr(108)+"8"+chr(68)+chr(27)+chr(38)+chr(108)+"90"+chr(80),;
    chr(27)+chr(38)+chr(107)+chr(52)+chr(83)+chr(27)+chr(38)+;
    chr(108)+"5"+chr(68)+chr(27)+chr(38)+chr(108)+"66"+chr(80),;
    chr(27)+chr(40)+chr(115)+"23"+chr(72)+chr(27)+chr(38)+chr(108)+;
    "10"+chr(68)+chr(27)+chr(38)+chr(108)+"90"+chr(80)}
endif
IF nHP = 5
   cTMPCAM := PROFILESTRING("PRINTER.INI","PATH","DOSPRNDBF","")
   netuse(cTMPCAM+"DOSPRN1","DBFCDX",.T.,.T.,.T.,.T.)
   DBFVIEW("' '+PR_NAME+' '+GRAPH_DRIV",10,10,20,50)
   cIMPCOM := FAZSPCCHR(ALLTRIM(COND_ON))
   cIMPEXP := FAZSPCCHR(ALLTRIM(COND_OFF))
   cIMPNEG := FAZSPCCHR(ALLTRIM(BOLD_ON))
   cIMPNER := FAZSPCCHR(ALLTRIM(BOLD_OFF))
   if !empty(cIMPCOM)
      aRETU[ 1 ] := &cIMPCOM.
   ENDIF
   IF !EMPTY(cIMPEXP)
      aRETU[ 2 ] := &cIMPEXP.
   ENDIF
   aRETU[ 3 ] := ""
   IF !EMPTY(cIMPNEG)
      aRETU[ 4 ] := &cIMPNEG.
   ENDIF
   IF !EMPTY(cIMPNEG)
      aRETU[ 5 ] := &cIMPNEG.
   ENDIF
   DBCLOSEALL()
endif
IF nHP = 6
   cTMPCAM := PROFILESTRING("PRINTER.INI","PATH","DOSPRNDBF","")
   netuse(cTMPCAM+"DOSPRN2","DBFCDX",.T.,.T.,.T.,.T.)
   DBFVIEW("' '+EMPRESA+' '+IMPRESS",10,10,20,50)
   aRETU[ 1 ] := ALLTRIM(CONDON)
   aRETU[ 2 ] := ALLTRIM(CONDOFF)
   aRETU[ 3 ] := ""
   aRETU[ 4 ] := ALLTRIM(NEGRON)
   aRETU[ 5 ] := ALLTRIM(NEGROFF)
   DBCLOSEALL()
endif
IF nHP = 7
   aRETU   := {"","",""}
   cTMPCAM := PROFILESTRING("PRINTER.INI","PATH","DOSPRNDBF","")
   netuse(cTMPCAM+"DOSPRN3","DBFCDX",.T.,.T.,.T.,.T.)
   DBFVIEW("NOME",10,10,20,50)
   if !empty(C_10CPI)
      aRETU[ 1 ] := &C_10CPI.
   ENDIF
   IF !EMPTY(C_17CPI)
      aRETU[ 2 ] := &C_17CPI.
   ENDIF
   //DOSPRN3 So tem comprimido expandido
   aRETU[ 3 ] := ""
   aRETU[ 4 ] := ""
   aRETU[ 5 ] := ""
   DBCLOSEALL()
endif
if nHP = 8
   aRETU := {"","","","",""}
endif
//Variaveis Publicas de Impressao
cIMPCOM := aRETU[1]
cIMPEXP := aRETU[2]
cIMPTIT := aRETU[3]
IF LEN(aRETU) > 3   //temporariamente ate pegar codigos posicoes 4,5 impressoras
   cIMPNEG := aRETU[4]
   ciMPNER := aRETU[5]
ELSE
   cIMPNEG := ""
   ciMPNER := ""
ENDIF
retu aRETU


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function FAZSPCCHR()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
FUNC FAZSPCCHR(cTEXTO)

LOCAL aUSO
LOCAL cUSO
aUSO := HB_ATokens(cTEXTO," ")
cUSO := ""
FOR X := 1 TO LEN(aUSO)
   IF !EMPTY(cUSO)
      cUSO := cUSO+"+"
   ENDIF
   IF !EMPTY(aUSO[X])
      cUSO := "CHR("+aUSO[X]+")"
   ENDIF
NEXT X
RETU cUSO



/*
*+¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
*+
*+
*+
*+    Function impext()
*+
*+
*+
*+¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡
*+
*+
*+
function impext( cARQ )
local X
local nRUN
local nTECLA
local cTELA
local cMENU
priv cRUN
cTELA := savescreen( 6, 10, 17, 70 )
CLSBOX( 6, 10, 17, 70 )
HB_dispbox( 6, 10, 17, 70, B_DOUBLE+" " )
while .T.
   for X := 1 to 20
      cMENU  := PROFILESTRING( "PRINTER.INI", "PRGEXT", "DES" + strzero( X, 2 ), "Nao Disponivel" )
      nTECLA := PROFILENUM( "PRINTER.INI", "PRGEXT", "TEC" + strzero( X, 2 ), 0 )
      oPCAO( if( X < 11, X + 6, X - 4 ), if( X < 11, 12, 32 ), cMENU, nTECLA )
   next x
   nRUN := menu(, 0 )
   if nRUN > 0
      exit
   endif
enddo
restscreen( 6, 10, 17, 70, cTELA )
cRUN := PROFILESTRING( "PRINTER.INI", "PRGEXT", "EXE" + strzero( nRUN, 2 ), "DIR" ) + " "
cRUN += PROFILESTRING( "PRINTER.INI", "PRGEXT", "PRE" + strzero( nRUN, 2 ), "" ) + " "
cRUN += cARQ + " "
cRUN += PROFILESTRING( "PRINTER.INI", "PRGEXT", "PAR" + strzero( nRUN, 2 ), "" ) + " "
cRUN := strtran( cRUN, "  ", " " )      //Tira duplos Espacos
bb_run(cRUN)
retu .t.
*/


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function FILETOEMAIL()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
FUNCTION FILETOEMAIL(cARQ,cASSUNTO,cCORPOMSG)

LOCAL cServerIP,nPort,cFrom,aTo,aArqEmail,cUser,cPass,cPop,cVAR
LOCAL cTELA
LOCAL nOPCAO
LOCAL lVAR
LOCAL aUSO
LOCAL cParams
aUSO := SALVAA()
cTO  := SPACE(60)
IF VALTYPE(cASSUNTO) <> "C"
   cASSUNTO := SPACE(60)
ENDiF
IF VALTYPE(cCORPOMSG) <> "C"
   cCORPOMSG := SPACE(60)
ENDIF
@ 14,00 CLEAR TO 24,79
@ 15,00 SAY "Para"                                  
@ 15,10 GET cTO        valid CheckEmail(cTO)        
@ 16,00 SAY "Assunto"                               
@ 16,10 GET cASSUNTO                                
@ 17,00 SAY "Mensagem"                              
@ 17,10 GET cCORPOMSG                               
READCUR()


sContaAtiva =PROFILESTRING("PRINTER.INI",ZUSER,"CONTAEMAIL","")  //nome para buscar no cofre
If sContaAtiva = "" 
    sContaAtiva = "PADRAO"   //usa email padrao
End 
cFROM      :=PROFILESTRING("PRINTER.INI",sContaAtiva,"ENDERECOEMAIL","")  //endereco do email do usuario ou do padrao envio
cCAMAPP   := PROFILESTRING("PRINTER.INI",sContaAtiva,"APPEMAIL","")+" "    //"C:\Program Files\Mozilla Thunderbird\thunderbird.exe "

cSERVERIP  :=lerDoCofre(sContaAtiva, "SmtpServer")
nPORT      :=LerDoCofre(sContaAtiva, "SmtpPort")
cUSER      :=LerDoCofre(sContaAtiva, "EmailUser") 
cPASS      :=LerDoCofre(sContaAtiva, "EmailPassword") 
cPOP       :=LerDoCofre(sContaAtiva, "PopServer") 

/*
cSERVERIP := PROFILESTRING("PRINTER.INI","EMAIL","SERVER")
nPORT     := VAL(PROFILESTRING("PRINTER.INI","EMAIL","PORTA"))
cUSER     := PROFILESTRING("PRINTER.INI","EMAIL","USUARIO")
cPASS     := PROFILESTRING("PRINTER.INI","EMAIL","SENHA")
cPOP      := PROFILESTRING("PRINTER.INI","EMAIL","POP")
*/

cTO := ALLTRIM(cTO)
cTO := lower(cTO)
cTO := STRTRAN(cTO,";",",")
IF AT(",",cTO) > 0
   aTO := HB_ATOKENS(cTO,",")
ELSE
   aTo := {cTO}
ENDIF
cASSUNTO  := ALLTRIM(cASSUNTO)
cCORPOMSG := ALLTRIM(cCORPOMSG)
IF VALTYPE(cARQ) = "C"
   aARQEMAIL := {cARQ}
ENDIF
IF VALTYPE(aARQEMAIL) <> "A"
   aARQEMAIL := {}
ENDIF

/*
   cServer    -> Required. IP or Domain name of the mail server
   nPort      -> Optional. Port used my email server
   cFrom      -> Required. Email address of the sender
   aTo        -> Required. Character String or array of email addresses to send the email to
   aCC        -> Optional. Character String or array of email adresses for CC (Carbon Copy)
   aBCC       -> Optional. Character String or array of email adresses for BCC (BLind Carbon Copy)
   cBody      -> Optional. The body Message of the email as text, or the Filename of the HTML Message to send.
   cSubject   -> Optional. Subject of the sending email
   aFiles     -> Optional. Array of attachments to the email to send
   cUser      -> Required. User name for the POP3 server
   cPass      -> Required. Password for cUser
   cPopServer -> Required. Pop3 server name or address
   nPriority  -> Optional. Email priority: 1=High, 3=Normal (Standard), 5=Low
   lRead      -> Optional. If Set to .T., a Confirmation request is send. Standard Setting is .F.
   lTrace     -> Optional. If Set to .T., a log File is created (sendmail<nNr>.log). Standard Setting is .F.
   */


cTELA := savescreen(6,0,17,80)
CLSBOX(6,0,17,80)

   HB_dispbox(6,0,17,79,B_DOUBLE+" ")
   oPCAO(07,01," &SendMail   ",73)   //S
   oPCAO(08,01," &MAPI       ",65)   //M
   oPCAO(09,01," &APP        ",69)   //A
   oPCAO(10,01," hb&NFeEmail ",78)   // N - Nova opção incluída
   nOPCAO := menu(,0)
restscreen(6,0,17,80,cTELA)   
   
   
lVAR := .F.   
IF nOPCAO=1
   TRY
      lVar := HB_SendMail(cServerIP,nPort,cFrom,aTo,,,cCorpoMsg,cAssunto,aArqEmail,cUser,cPass,cPop,3,.F.,.T.)
   catch
      lVAR := .F.
   END
   
ENDIF
IF nOPCAO=2
    lVAR := .T.
    TRY
        win_MAPISendMail(;
         cAssunto,;   // subject
         cCorpoMsg,;  // menssage
         NIL,;  // type of message
         DToS(Date())+" "+Time(),;  // send date
         "",;   // conversation ID
         .F.,;  // acknowledgment
         .T.,;  // user intervention
         {cfrom},;  // sender
         aTO,;  // destinators
         aArqEmail)   // attach
          lVAR := .T.
    catch
        lVAR := .F.
    END

ENDIF

IF nOPCAO=3
  //LOCAL cCAMAPP := "C:\Program Files\Mozilla Thunderbird\thunderbird.exe " cCAMAPP   := PROFILESTRING("PRINTER.INI","EMAIL","APP")+" " 
  //LOCAL cCommand := "-compose "
  //LOCAL cTo      := "to='Joh...@example.org,TheOt...@example.org'"
  //LOCAL cCC      := "cc='TheOther...@example.com'"
  //LOCAL cBcc     := "bcc='TheHidden...@example.com'"
  //LOCAL cSub     := "subject='dinner'"
  //LOCAL cBody    := "body='How Do I Use Thunderbird to send emails through Harbour program?'"
  //LOCAL cAttach  := "attachment='"+ __FILE__ + "'"
   //AList( { cTo, cCC, cBcc, cSub, cBody, cAttach }, "," )
   //cParams := AList( { cTo, cCC, cBcc, cSub, cBody, cAttach }, "," )
   
   //aTo,,,cCorpoMsg,cAssunto,aArqEmail,cUser,cPass,cPo
   
   
   cAttach  := "attachment='"+ cARQ + "'"
   cSub     := "subject='"+ cAssunto + "'"
   cBody    := "body='"+ cCorpoMsg + "'"
   cDESTINO := "to='"+ cTO + "'"
   
   cParams := ArraytoTexto( { cDestino,  cSub, cBody, cAttach }, "," )
   
   //? "Sending mail..."
   WaitProcess( cCAMAPP + "-compose " + cParams )
   //? "Mail sent ..." 
   lVAR := .t.




ENDIF


IF nOPCAO=4
// Instancia o objeto da classe hbnfeemail
   oEmail := hbNFeEmail():New()

   // Converte para minúsculo e limpa espaços para garantir a comparação automatizada
   cServerLower := AllTrim( Lower( cServerIP ) )

   // DESCOBERTA E ESCOPO AUTOMÁTICO ADADEQUADO AO SERVER DO INI
   DO CASE
      CASE "gmail" $ cServerLower
         // Se no INI estiver smtp.gmail.com ou similar
         // O método UseGmail já configura internamente a porta 465, SSL direto e associa o From ao usuário [cite: 11, 12, 13]
         oEmail:UseGmail( cUser, cPass ) 

      CASE "office365" $ cServerLower .OR. "outlook" $ cServerLower
         // Se no INI estiver smtp.office365.com ou smtp.mail.outlook.com
         // O método UseMicrosoft365 configura os canais internos da Microsoft (Porta 587, TLS, SSL) [cite: 16, 17, 100]
         oEmail:UseMicrosoft365( cUser, cPass )

      CASE "brevo" $ cServerLower
         // Se no INI estiver smtp-relay.brevo.com
         // O método UseBrevo aceita: cSmtpLogin, cSmtpKey, cFrom, nPorta [cite: 114]
         oEmail:UseBrevo( cUser, cPass, cFrom, nPorta ) 

      OTHERWISE
         // Servidor genérico do INI (Ex: mail.seudominio.com.br, smtp.terra.com.br, etc) [cite: 74]
         // Passa os parâmetros explícitos lidos do seu INI
         // Parâmetros: cServer, nPorta, cUsuario, cSenha, lSSL, lTLS 
         oEmail:UseSMTP( cServer, nPorta, cUser, cPass, (nPorta == 465), (nPorta == 587) )
   ENDCASE

   // Preenche os dados dinâmicos recebidos nos parâmetros da função
   oEmail:cSubject  := cASSUNTO
   oEmail:cMsgTexto := cCORPOMSG
   
   // Se cFrom estiver populado diferentemente do padrão mapeado nos métodos, força o do INI [cite: 13, 16, 18]
   IF ! Empty( cFrom )
      oEmail:cFrom := cFrom
   ENDIF

   // Adiciona o destinatário (Supondo que você use uma variável global ou passe no bloco)
   // oEmail:AddTo( cDESTINATARIO ) [cite: 107]

   // Adiciona o anexo passado no parâmetro se ele existir fisicamente
   IF ! Empty( cARQ ) .AND. File( cARQ )
      oEmail:AddFile( cARQ ) 
   ENDIF

   // Executa o Envio via CDO Component [cite: 62, 107]
   aRet := oEmail:Execute()

   IF ! aRet["OK"] 
      // Trate o erro conforme a sua estrutura de mensagens (Ex: MsgStop, AlertX, etc)
      Alert( "Erro no envio pelo provedor [" + aRet["Provider"] + "]: " + aRet["MsgErro"] )
      RETURN .F.
   ENDIF


ENDIF

If lVar
   cVar := "Envio Ok"
Else
   cVar := "Erro no Envio"
EndIf
ALERTX(cVar)

RESTAA(aUSO)
return .t.


*+--------------------------------------------------------------------
*+
*+
*+
*+    Function filetoprwin()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
FUNCTION filetoprwin(cARQ,nTIPO)

LOCAL cPRINTER
LOCAL aPRN,vaprinter
LOCAL nRESP
LOCAL i
LOCAL nSTATUS
cPRINTER  := WIN_PRINTERGETDEFAULT()
vaPrinter := WIN_PRINTERLIST(.T.)
If Empty(vaPrinter)
   ALERTX("Nenhuma impressora instalada")
   retu .f.
EndIf
aPrn := {}
// Laco para montar o array com
// todas as impressoras
For i := 1 TO Len(vaPrinter)
   if cPrinter = vaPrinter[i,1]   // Se for a padrao
      // Coloca um (P) antes do nome
      AADD(aPrn,"(P) "+vaPrinter[i,1]+' em '+vaPrinter[i,2])
   else
      // Armazena as outras
      AADD(aPrn,"    "+vaPrinter[i,1]+' em '+vaPrinter[i,2])
   endif
Next
cTELA := savescreen(5,5,17,75)
HB_DISPBOX(5,5,17,75,B_DOUBLE+" ")
nRESP  := ACHOICE(6,6,16,74,aPrn)
cPorta := ""
if lastkey() = 13
   cPRINTER := vaprinter[nRESP,1]   //pega nome impressora a matriz original
   cPorta   := vaprinter[nRESP,2]   //pega a porta
   //ALERTX(cPRINTER)
   nStatus := PrintStat(cPrinter)
   if nSTATUS > 0
      if !mdg("Continuar a impressora: "+IsImpressora(cPrinter))
         retu .f.
      endif
   endif
else
   ALERTX("Nao Selecionada")
   retu .F.
endif
RESTscreen(5,5,17,75,CTELA)


oPrinter := Win_Prn():new(cPrinter)
oPrinter:create()
oPrinter:startDoc()
nLar := oPrinter:pagewidth()  //Larqura
nAlt := oPrinter:pageheight()   //Altura
nCor := oPrinter:numcolors()  //ncores
oPrinter:enddoc()
oPrinter:destroy()
lMatrix := .F.
IF SUBSTR(UPPER(cPorta),1,3) = "LPT" .AND. nCor < 3 .AND. nLar < 1000 .AND. nAlt < 2000
   lMatrix := .T.
ENDIF
cPRINTER := ALLTRIM(cPRINTER)
IF VALTYPE(NTIPO) <> "N"
   IF MDG("Use SIM=PrinterFileRaw NAO=W32PRN")
      nTIPO := 1
   ELSE
      nTIPO := 2
   ENDIF
ENDIF

IF nTIPO = 1
   //
   //PrintFileRaw(cPRINTER,cFile,cTITULO)
   //
   //   nPrn := PrintFileRaw(cPRINTER,cARQ,"Imprimindo:"+cARQ)
   nPrn := WIN_PrintFileRaw(cPRINTER,cARQ,"Imprimindo:"+cARQ)
   IF nPRN < 0
      DO CASE
      CASE nPrn = - 1
         ALERTX("Parametros Invalido, Favor Tentar Novamente")
      CASE nPrn = - 2
         ALERTX("Falha na chamada da Impressora, Favor Verificar a Impressora")
      CASE nPrn = - 3
         ALERTX("Falha ao Iniciar Impressao, Favor Verificar a Impressora")
      CASE nPrn = - 4
         ALERTX("Falha ao Iniciar a Primeira Pagina, Favor Verificar a Impressora")
      CASE nPrn = - 5
         ALERTX("Falha de Memoria da Impressora, Favor Verificar a Impressora")
      CASE nPrn = - 6
         ALERTX("Nao foi Possivel localizar o arquivo de Impressao, Favor Tentar Novamente")
      OTHERWISE
         //ALERTX(cFileName+" PRINTED OK!!!?")
      ENDCASE
   ENDIF
ELSE
   PrintUSB(cARQ,cPRINTER)
ENDIF
retu .t.

*+--------------------------------------------------------------------
*+
*+
*+
*+    Function PrintUSB()
*+
*+
*+
*+--------------------------------------------------------------------
*+
*+
*+
Function PrintUSB(DocPrinter,xPRINTER)

Local mDocPrint,vDocPrint,nA,nLand,nLin := 1,nTamPag,cMsg,i
Local aCAMPOS,cMACRO,bBLOCK,aACENTOS

// =======================================================================
// NOVA MATRIZ: Mapeia as tags [BBCode] para as Macros dinâmicas do Win32Prn
// =======================================================================
aACENTOS := {}
AADD(aacentos,{"[B]", "oPrinter:bold(700)"})                 // Negrito ON
AADD(aacentos,{"[/B]", "oPrinter:bold(400)"})                // Negrito OFF
AADD(aacentos,{"[I]", "oPrinter:Italic( .T. )"})             // Italico ON
AADD(aacentos,{"[/I]", "oPrinter:Italic( .F. )"})            // Italico OFF
AADD(aacentos,{"[U]", "oPrinter:UnderLine( .T. )"})          // Sublinhado ON
AADD(aacentos,{"[/U]", "oPrinter:UnderLine( .F. )"})         // Sublinhado OFF

// Traducao dos Tamanhos baseada na sua logica original
AADD(aacentos,{"[SIZE=8]", "oPrinter:SetFont('Courier',8,{3,-50}),oPrinter:bold( 100 )"}) 
AADD(aacentos,{"[SIZE=12]", "oPrinter:setFont('Courier',8),oPrinter:bold( 200 )"}) 
AADD(aacentos,{"[SIZE=14]", "oPrinter:setFont('Courier',12),oPrinter:bold( 400 )"}) 

// Comando de Salto de Pagina
AADD(aacentos,{"[PAGE]", "oPrinter:newPage(),nLin := 1"})   

oPrinter := Win32Prn():new(xPrinter)  // Crio a instancia da impressora

// Leio o arquvo gerado do diretorio temp ou outro qualquer
mDocPrint := hb_memoread(DocPrinter)

// Verifica se vai imprimir em Retrato (nLand=.f.)
// ou Paisagem (nLand=.t.)
nLand   := .f.
nTamPag := 62   // 62 Linhas em modo Retrato ou 45 em modo Paisagem
IF EMPTY(cIMPORI)
   // Faco um laco para pegar a maior linha
   for nA := 1 to MLCount(mDocPrint,229)
      vDocPrint := rTrim(MemoLine(mDocPrint,229,nA))
      if len(vDocPrint) > 116   // Se a linha for maior
         nLand   := .t.   // Muda para Paisagem
         nTamPag := 45  // (Re)Configura o numero de linhas
         exit   // Mudou, nao precisa continuar
      endif
   next
ELSE
   IF cIMPORI = "R"
      nLand   := .f.
      nTamPag := 62   // 62 Linhas em modo Retrato ou 45 em modo Paisagem
   ENDIF
   IF cIMPORI = "P"
      nLand   := .t.  // Muda para Paisagem
      nTamPag := 45   // (Re)Configura o numero de linhas
   ENDIF
ENDIF

// Mostra mensagem no rodape
@ maxrow(), 0 say iif(nLand,"Imprimindo em modo Paisagem","Imprimindo em modo Retrato")         

oPrinter:landscape := nLand

// 9 = DIN A4 format 210 x 297 mm
oPrinter:formType := 9  // Papel A4
oPrinter:copies := 1  // Numero de copias

// Cria dispositivo de impressao
If .not. oPrinter:create()
   ALERTX("Nao foi possivel criar o dispositivo de impressao")
   return (.f.)
EndIf

// Criar trabalho de impressao
If .not. oPrinter:startDoc(DocPrinter)  // Encarrega o spooler para comecar com um novo documento
   ALERTX("Nao foi possivel criar o documento")
   return (.f.)
EndIf

oPrinter:setFont("Courier",8)   // Fonte Courier
oPrinter:bold(200)

vtTeste := "Entrada"

// Laco para imprimir linha por linha
for nA := 1 to MLCount(mDocPrint,229)
   vDocPrint := rTrim(MemoLine(mDocPrint,229,nA))
   
   // =======================================================================
   // CONVERSÃO DE BINÁRIOS PARA BBCODE ANTES DE PROCESSAR
   // =======================================================================
   vDocPrint := ParseEscapeToBBCode( vDocPrint )

   // Aceita o padrao antigo e o novo [PAGE] para manter retrocompatibilidade
   IF at("\\PAGE\\",UPPER(vDocPrint)) > 0 .OR. at("[PAGE]", UPPER(vDocPrint)) > 0
      nLin      := nTamPag - 1
      vDocPrint := strtran(vDocPrint,"\\page\\","")
      vDocPrint := strtran(vDocPrint,"\\PAGE\\","")
      vDocPrint := strtran(vDocPrint,"[PAGE]","")
   ELSE

      // Imprime a linha executando as substituicoes
      for i := 1 to len(aacentos)
         vDocPrint := strtran(vDocPrint,aacentos[i,1],"\\#"+aacentos[i,2]+"\\")
      next i

      aCAMPOS := HB_ATokens(vDocPrint,"\\")

      IF LEN(aCAMPOS) > 0
         FOR i := 1 TO LEN(aCAMPOS)
            IF SUBSTR(aCAMPOS[i],1,1) = "#"
               cMACRO := SUBSTR(aCAMPOS[i],2)
               // Executa a macro do Win32Prn diretamente
               bBlock := &("{||"+cMacro+"}")
               EVAL(Bblock)
            ELSE
               oPrinter:textOut(rTrim(aCAMPOS[i]))
            ENDIF
         NEXT i
      ELSE
         oPrinter:textOut(rTrim(vDocPrint))
      ENDIF

      // Insere uma nova linha
      oPrinter:newLine()

      oPrinter:setFont("Courier",8)   // Fonte Courier 8
      oPrinter:bold(200)  // 200
      
   endif
   
   nLin ++
   // Verifica se chegou no final da pagina
   if nLin > nTamPag  
      nLin := 1
      oPrinter:newPage()
   endif
next

// Envia saida para impressora
oPrinter:endDoc()

// Encerra a impressao e destroi o objeto
oPrinter:destroy()
Return (.t.)

*+ EOF: flib08.prg
*+
