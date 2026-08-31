// +--------------------------------------------------------------------
// +
// +
// +
// +    Programa  : disk61.prg  Imprimir Arquivos de Textos
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
// +    Documentado em 28-Dez-2024 as 10:41 am
// +
// +
// +
// +--------------------------------------------------------------------
// +


// !*****************************************************************************
// !
// ! Funcaoo: IMPARQ(xarquivo,msetup,mmarlin,mmarinf,mmarsup,mmaresq,mmardir,mmarcol,mgraf)
// ! xARQUIVO  Nome do Arquivo
// ! mMARLIN   Numero de Linhas do Formul rio
// ! mMARINF   Margem Inferior
// ! mMARSUP   Margem Superior
// ! mMARESQ   Margem Esquerda
// ! mMARDIR   Margem Direita
// ! mMARCOL   Numero de Coluna por folha
// ! mGRAF     Imprimir Caracteres Graficos
// !
// !*****************************************************************************

FUNCTION imparq( xarquivo, msetup, mmarlin, mmarinf, mmarsup, mmaresq, mmardir, mmarcol, mgraf )

   PRIV texto, Fim, meio, X, y, mlinha

// Checando os Parametos
   IF ValType( xarquivo ) # "C"
      ALERTX( "Falta nome de Arquivo" )
      RETU .F.
   ENDIF
   IF !File( xarquivo )
      ALERTX( "Arquivo nao Encontrado" )
      RETU .F.
   ENDIF
   nHANDLE := hb_fopen( xARQUIVO )
   IF nHANDLE = 0
      ALERTX( "Arquivo nAo Pode ser Aberto" )
   ENDIF
   IF ValType( msetup ) # "C"
      msetup := ""
   ENDIF
   IF ValType( mmarlin ) # "N" .OR. Empty( mmarlin )
      mmarlin := 66
   ENDIF
   IF ValType( mmarinf ) # "N"
      mmarinf := 0
   ENDIF
   IF ValType( mmarsup ) # "N"
      mmarsup := 0
   ENDIF
   IF ValType( mmaresq ) # "N"
      mmaresq := 0
   ENDIF
   IF ValType( mmardir ) # "N"
      mmardir := 0
   ENDIF
   IF ValType( mmarcol ) # "N" .OR. Empty( mmarcol )
      mmarcol := 80
   ENDIF
   IF ValType( mGRAF ) = "C"
      IF mGRAF = "S"
         mGRAF := .T.
      ENDIF
      IF mGRAF = "N"
         mGRAF := .F.
      ENDIF
   ENDIF
   IF ValType( mgraf ) # "L"
      mgraf := .F.
   ENDIF

   IF !CHECKIMP( 0 )
      RETU .F.
   ENDIF
   IMPRESSORA()
   IF !Empty( msetup )
      msetup := AllTrim( msetup )
      @ PRow(), 0 SAY &msetup
   ENDIF
   meio := mmarlin - ( mmarsup * 2 ) - mmarinf
   lFIM := .F.
   WHILE !lFIM
      @ PRow() + mmarsup, 0 SAY ""
      FOR y := 1 TO meio
         WHILE !lFIM
            mLINHA := RTrim( FREADLINE( nHANDLE ) )
            mLINHA := Left( mLINHA, mmarcol - mmaresq - mmardir )
            IF mLINHA = "__FINAL__"
               lFIM := .T.
            ELSE
               @ PRow() + 1, mmaresq SAY mlinha
            ENDIF
         ENDDO
      NEXT y
      @ PRow() + mmarinf, 0 SAY ""
   ENDDO
   FClose( nHANDLE )
   IMPFOL()
   VIDEO()
   IMPEND()
   RETU .T.






// +--------------------------------------------------------------------
// +
// +
// +
// +    Function tipogra() Corrige Quadro para Impress„o
// +
// +
// +
// +--------------------------------------------------------------------
// +
// +
// +

FUNC tipogra( texto )

   aORI  := { 'Ý', 'Ý', 'µ', '¶', 'Ý', 'Ý', '+', 'Æ', 'Ç', 'Ý', '×', 'Ø', 'Ý', 'Ý', 'Þ' }
   aDES  := { '|', '|', '|', '|', '|', '|', '|', '|', '|', '|', '|', '|', '|', '|', '|' }
   texto := charconv( texto, aORI, aDES )
   aORI  := { '·', '¸', '+', '+', '½', '¾', '+', '+', '-', '-', '-', '+', '+', '+', '-', '-', '-', '+', 'Ï', 'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'i', 'Ö', '+', '+', '_', 'î' }
   aDES  := { '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-', '-' }
   texto := charconv( texto, aORI, aDES )
   RETUrn texto

// : FIM: DISK61.PRG

