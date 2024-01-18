// Programa   : DPTABLAGRID
// Fecha/Hora : 09/03/2007 12:10:21
// Propósito  : Crear y Modificar Estructuras de Tablas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(nOption,cTable,oLbx)
   LOCAL lVista:=.F.
   LOCAL cScope:="",cSql
   LOCAL aDsn:=LoadDsn(),aAplica:={},aChoice:={}
   LOCAL oGrid,oFontB,oFont,oCol,nAt

   DEFAULT nOption:=0,;
           cTable :=SQLGET("DPTABLAS","TAB_NOMBRE","TAB_VISTA=0")

   SysRefresh(.T.)

/*
   // 15/03/2016
   EJECUTAR("SETFIELDLONG","DPCAMPOS"  ,"CAM_COMMAN" ,80)
   EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_VISTA" ,"L",01,0,"Vista")
   EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXSUC","L",01,0,"Restricción por Sucursal")
   EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_REXUSU","L",01,0,"Restricción por Usuario")
   EJECUTAR("DPCAMPOSADD" ,"DPTABLAS"  ,"TAB_CAMDES","C",20,0,"Campo Descripción")
*/         
   lVista:=SQLGET("DPTABLAS","TAB_VISTA","TAB_NOMBRE"+GetWhere("=",cTable))

   IF lVista
     MsgMemo("Tabla pertenece a una Vista")
     RETURN .F.
   ENDIF

   IF nOption=1
      cScope:="1=0"
   ENDIF

   IF !Empty(cTable) .AND. (nOption=3 .OR. nOption=0)
      cScope:="TAB_NOMBRE"+GetWhere("=",cTable)
   ENDIF

   DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -12
   DEFINE FONT oFont  NAME "Times New Roman"   SIZE 0, -12

   aDsn:={}
   AADD(aDsn,"<MULTIPLE>")
   AADD(aDsn,".CONFIGURACION")
   AADD(aDsn,"-DICCIONARIO")

   aAplica  :=ASQL("SELECT MNU_MODULO,MNU_TITULO FROM DPMENU WHERE MNU_VERTIC='A' ORDER BY MNU_MODULO")

   AEVAL(aAplica, {|a,n| AADD(aChoice,a[2] ) })

   DOCENC(IF(nOption=3,"Modificar","")+" Definición de Tablas","oDpTabla","DPTABLASX.EDT")

   oDpTabla:lBar:=.T.
   oDpTabla:SetScope(cScope)
   oDpTabla:SetTable("DPTABLAS","TAB_NOMBRE",cScope) 

   oDpTabla:cNumero    :=oDpTabla:TAB_NUMERO
   oDpTabla:cNombre    :=oDpTabla:TAB_NOMBRE
   oDpTabla:TAB_NOMBRE_:=oDpTabla:TAB_NOMBRE

   oDpTabla:cNombre_  :=oDpTabla:cNombre
   oDpTabla:nOption   :=nOption

   oDpTabla:oLbx      :=oLbx
   oDpTabla:lFind     :=.T.
   oDpTabla:lAutoEdit :=(nOption=3)
   oDpTabla:lHead     :=.T.
   oDpTabla:aAplica   :=ACLONE(aAplica)

   oDpTabla:cPrimary  :="TAB_NOMBRE"
   oDpTabla:cPreSave  :="PRESAVE"
   oDpTabla:cPostSave :="POSTGRABAR"

   oDpTabla:cList:="DPTABLASEL.BRW"

   oDpTabla:Windows(0,0,450+200+20,790+350+60)

   @ 4,20 SAY "Nombde de la Tabla:"
   @ 4,40 SAY "Base de Datos"
   @ 5,10 SAY "Descripción Plural"
   @ 5,20 SAY "Utilización"

   @ 04.0,0 SAY "Descripción Singular"

/*

   @ 5,0 GET oDpTabla:oTAB_NUMERO VAR oDpTabla:TAB_NUMERO PICTURE "9999" VALID CERO(oDpTabla:TAB_NUMERO).AND.;
             oDpTabla:ValUnique(oDpTabla:TAB_NUMERO);
             WHEN (AccessField("DPTABLAS","TAB_NUMERO",oDpTabla:nOption);
                    .AND. oDpTabla:nOption!=0)

*/

   @ 12,0 GET oDpTabla:oTAB_NOMBRE VAR oDpTabla:TAB_NOMBRE VALID oDpTabla:ValUnique(oDpTabla:TAB_NOMBRE,"TAB_NOMBRE");
                             .AND. oDpTabla:VALNOMBRE();
                             .AND. !VACIO(oDpTabla:TAB_NOMBRE);
                             .AND. oDpTabla:ValUnique(oDpTabla:TAB_NOMBRE);
                             WHEN (AccessField("DPTABLAS","TAB_NOMBRE",oDpTabla:nOption);
                                   .AND. oDpTabla:nOption!=0);
                                   PICTURE "@!"


   @ 13,0 GET oDpTabla:oTAB_DESCRI VAR oDpTabla:TAB_DESCRI;
              VALID !EMPTY(oDpTabla:TAB_DESCRI);
              WHEN (AccessField("DPTABLAS","TAB_DESCRI",oDpTabla:nOption);
                    .AND. oDpTabla:nOption!=0);

 
   @ 14,12 COMBOBOX oDpTabla:oTAB_DSN VAR oDpTabla:TAB_DSN;
           ITEMS aDsn ;
           WHEN (AccessField("DPTABLAS","TAB_DSN",oDpTabla:nOption);
                 .AND. oDpTabla:nOption!=0);


   @ 15,25 COMBOBOX oDpTabla:oTAB_APLICA VAR oDpTabla:TAB_APLICA;
           ITEMS aChoice;
           WHEN (AccessField("DPTABLAS","TAB_APLICA",oDpTabla:nOption);
                 .AND. oDpTabla:nOption!=0);

   COMBOINI(oDpTabla:oTAB_APLICA)

   @ 16,0 GET oDpTabla:oTAB_SINGUL VAR oDpTabla:TAB_SINGUL;
              WHEN (AccessField("DPTABLAS","TAB_SINGUL",oDpTabla:nOption);
                     .AND. oDpTabla:nOption!=0);

   // Cuerpo del ComboBox


   @ 6,1 CHECKBOX oDpTabla:TAB_REXSUC PROMPT ANSITOOEM("Restricción por Sucursal");
         WHEN "<"$oDpTabla:TAB_DSN

   @ 7,1 CHECKBOX oDpTabla:TAB_REXUSU PROMPT ANSITOOEM("Restricción por Usuario")

   @ 7,1 CHECKBOX oDpTabla:TAB_CATLGO PROMPT ANSITOOEM("Catálogo")
          
          

   cSql  :="SELECT * FROM DPCAMPOS "
   cScope:=""

// oGrid:=oDpTabla:GridEdit( "DPCAMPOS" ,"TAB_NUMERO", "CAM_NUMTAB" , cSql , cScope ) 
   oGrid:=oDpTabla:GridEdit( "DPCAMPOS" ,"TAB_NOMBRE", "CAM_TABLE"   , cSql , cScope ) 


   oGrid:cScript    :="DPTABLAGRID"
   oGrid:aSize      :={150-20,0,780+300+100+5,200+190}
   oGrid:oFont      :=oFontB
   oGrid:bValid     :="!EMPTY(oDpTabla:TAB_NOMBRE)"
   oGrid:bWhen      :=oGrid:bValid
// oGrid:cItem      :="CAM_ITEM"
   oGrid:cLoad      :="GRIDLOAD"
   oGrid:cPresave   :="GRIDPRESAVE"
   oGrid:cPostSave  :="GRIDPOSTSAVE" 
   oGrid:cPreDelete :="GRIDPREDELETE"
   oGrid:cPostDelete:="GRIDPOSTDELETE" 
 
   oGrid:nClrPane1   :=oDp:nGrid_ClrPane1 //15724527
   oGrid:nClrPane2   :=oDp:nGrid_ClrPane2 // 16316664
// oGrid:nClrPaneH   :=12578047
   oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
   oGrid:nClrTextH   :=0 
   oGrid:nHeaderLines:=2 
   oGrid:nRecSelColor:=oDp:nLbxClrHeaderPane // 12578047 // 16763283

   oGrid:lTotal       :=.T.

   oGrid:bClrHeader   := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oGrid:AddBtn("IMPORTAR.BMP","Importar Desde DBF","oGrid:nOption<>0",;
                [EJECUTAR("DPTABLASIMPDBF",oGrid)],"IMP")

   oGrid:AddBtn("ADJUNTAR2.BMP","Agregar Campo para Digitalización","oGrid:nOption=1",;
                [EJECUTAR("DPFIELDADDADJ",oDpTabla:TAB_NOMBRE,oGrid,"FILMAI","Registro para Digitalización")],"ADJ")

   oGrid:AddBtn("XMEMO2.BMP","Agregar Campo para Descripción Amplia","oGrid:nOption=1",;
                [EJECUTAR("DPFIELDADDADJ",oDpTabla:TAB_NOMBRE,oGrid,"NUMMEM","Registro para Descripción Amplia")],"ADJ")

   oGrid:AddBtn("primarykey.BMP","Agregar Clave Primaria","oGrid:nOption<>0",;
                [oGrid:SET_PRIMARYKEY()],"ADJ")


   // Campo Código
   oCol:=oGrid:AddCol("CAM_NAME")
   oCol:cTitle   :="Campo"
   oCol:bValid   :={||oGrid:CAMNAME(oGrid:CAM_NAME)}
   oCol:cMsgValid:="Campo no puede estar Vacio"
   oCol:nWidth   :=100+40
   oCol:lPrimary :=.T.
// oCol:cEditPicture:="@K !!!!!!!!!!"
   oCol:cPicture:="@K !!!!!!!!!!"
   oCol:lItems   :=.T.

   oCol:=oGrid:AddCol("CAM_TYPE")
   oCol:cTitle   :="Tipo"
   oCol:aItems   :={"Caracter","Numérico","Date/Fecha","Memo","Lógico","Blob","Int"}
//   oCol:aItemsData:={"C","N","D","M","L"}
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) }
   oCol:nWidth    :=060
   oCol:bPostEdit := {|| oGrid:SETLENFIELD() }


   oCol:=oGrid:AddCol("CAM_LEN")
   oCol:cTitle    :="Longi"+CRLF+"tud"
   oCol:bValid    :={|| oGrid:CAMLEN()}
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) .AND. LEFT(oGrid:CAM_TYPE,1)$"INC" }
   oCol:nWidth    :=40
   oCol:cPicture  :="9999"
   oCol:lTotal    :=.T.
   oCol:cMsgValid :="Campo Requiere Longitud"

   oCol:=oGrid:AddCol("CAM_DEC")
   oCol:cTitle    :="Dec"
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) .AND. LEFT(oGrid:CAM_TYPE,1)="N" }
   oCol:nWidth    :=30
   oCol:cPicture  :="9999"
   oCol:lTotal    :=.T.
   oCol:bValid    :={|| oGrid:VALCAMDEC()}

   oCol:=oGrid:AddCol("CAM_COMMAN")
   oCol:cTitle    :="Comando SQL"
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME)  }
   oCol:nWidth    :=200+40
   oCol:bValid    :={||oGrid:CAMCOMMAN(oGrid:CAM_COMMAN)}
   oCol:nEditType :=EDIT_GET_BUTTON
   oCol:bEditBlock:={||oGrid:DLGBRW()}

// oCol:bOnPostEdit  :={|oCol,uValue| oPRYINVCO:VAL_ETAPA(uValue,oCol) }


   oCol:=oGrid:AddCol("CAM_DESCRI")
   oCol:cTitle    :="Descripción del Campo"
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) }
// oCol:bValid    :={|| LEFT(oGrid:CAM_TYPE,1)$"NC" .AND. oGrid:CAM_LEN>0 }
// oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) .AND. LEFT(oGrid:CAM_TYPE,1)$"NC" }
   oCol:nWidth    :=235-40

   oCol:=oGrid:AddCol("CAM_ZERO")
   oCol:cTitle   :="Cero"
   oCol:nWidth   :=36
   oCol:nEditType:=0
   oCol:bWhen     :={|| Left(oGrid:CAM_TYPE,1)="C" }
   oCol:bValid    :={|| oGrid:VALZERO(oGrid:CAM_ZERO)}

   oCol:=oGrid:AddCol("CAM_MILES")
   oCol:cTitle   :="Miles"
   oCol:nWidth   :=36
   oCol:nEditType:=0
   oCol:bWhen     :={|| Left(oGrid:CAM_TYPE,1)="N" .AND. oGrid:CAM_LEN>3}
   oCol:bValid    :={|| oGrid:VALMILES(oGrid:CAM_MILES)}

   oCol:=oGrid:AddCol("CAM_AFECTA")
   oCol:cTitle   :="Afecta"+CRLF+"Vinculo"
   oCol:nWidth   :=43
   oCol:nEditType:=0
   oCol:bWhen     :={|| Left(oGrid:CAM_TYPE,1)="C"}
//   oCol:bValid    :={|| oGrid:VALMILES(oGrid:CAM_MILES)}


   oCol:=oGrid:AddCol("CAM_FORMAT")
   oCol:cTitle    :="Formato"
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME) .AND. LEFT(oGrid:CAM_TYPE,1)$"NC" }
   oCol:nWidth    :=140-30


   oCol:=oGrid:AddCol("CAM_DEFAUL")
   oCol:cTitle    :="Valor por Defecto"
   oCol:bWhen     :={|| !Empty(oGrid:CAM_NAME)  }
   oCol:nWidth    :=110-10

   oCol:=oGrid:AddCol("CAM_UPDATE")
   oCol:cTitle   :="Update"
   oCol:nWidth   :=46
   oCol:nEditType:=0


   oCol:=oGrid:AddCol("CAM_DEFFIJ")
   oCol:cTitle   :="Def/Def"+CRLF+"Fija"
   oCol:nWidth   :=46
   oCol:nEditType:=0
   oCol:bWhen     :={|| !Empty(oGrid:CAM_DEFAUL)}

   @ 12,1 SAY oDpTabla:oSayPrimary PROMPT "Clave Primaria"

//   @ 12,1 GROUP oDpTabla:oGrupo TO 14, 80 PROMPT "Primary Key"    

   @ 16,0 BMPGET oDpTabla:oTAB_PRIMAR VAR oDpTabla:TAB_PRIMAR;
                 NAME "BITMAPS\VIEW2.BMP";
                 VALID oDpTabla:VALPRIMARY();
                 SIZE 360+40,NIL;
                 ACTION oDpTabla:LISTCAMPO();
                 WHEN (AccessField("DPTABLAS","TAB_PRIMAR",oDpTabla:nOption);
                     .AND. oDpTabla:nOption!=0)

   oDpTabla:ACTIVATE( {|| oDpTabla:INICIO() })

   EJECUTAR("FRMMOVEDOWN",oDpTabla:oSayPrimary,oDpTabla,{oGrid:oBrw})

RETURN .T.

FUNCTION INICIO()

   oDpTabla:SAYSTRUCT()
   oDpTabla:oFocusFind :=oDpTabla:oTAB_NOMBRE

//   IF !Empty(oDpTabla:cScope) .AND. !Empty(nOption)
//     oDpTabla:nOption:=nOption
//     oDpTabla:LoadData()
//   ENDIF

  IF Valtype(oDpTabla:oLbx)="O"
     oDpTabla:oLbx:End()
  ENDIF

RETURN .T.

FUNCTION PREDELETE()

   oDpTabla:cDelete:=oDpTabla:TAB_NOMBRE

   IF !MsgNoYes("Desea Eliminar Tabla "+oDpTabla:TAB_NOMBRE)
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION POSTDELETE()
//SQLDELETE("DPCAMPOS","CAM_NUMTAB"+GetWhere("=",oDpTabla:TAB_NUMERO))
  SQLDELETE("DPCAMPOS","CAM_TABLE" +GetWhere("=",oDpTabla:TAB_NOMBRE))
RETURN .T.

FUNCTION CANCEL()

   IF !Empty(oDpTabla:cScope)
       oDpTabla:lAutoEdit:=.T.
       oDpTabla:Close()
   ENDIF

RETURN .T.

FUNCTION CAMNAME(cField)

   LOCAL cChar:=UPPE(LEFT(cField,1)),I,cInvalid:=":"

   IF Empty(cField)
      RETURN .F.
   ENDIF

   IF cChar!="_" .AND. (cChar<"A".OR.cChar>"Z")
      MsgAlert("El Primer Caracter debe ser A...Z")
      RETURN .F.
   ENDIF

   // Valida los Caracteres Permitidos
   cField:=UPPE(ALLTRIM(cField))
   FOR I:=1 TO LEN(cField)
      cChar:=UPPE(SUBS(cField,I,1))
      IF (cChar>="A".AND.cChar<="Z").OR.cChar$"1234567890_"
         cChar=""        
      ENDIF
   NEXT I

   IF Empty(cChar) .AND. ":"$cField
      cChar:=":"
   ENDIF

   IF !EMPTY(cChar)
      MsgAlert("Caracter ["+cChar+"] Inválido ")
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION SETLENFIELD()

   LOCAL aType:={"L","M","D","B"}
   LOCAL aLen :={01 ,0 ,08, 0 }
   LOCAL nAt  :=ASCAN(aType,LEFT(oGrid:CAM_TYPE,1))

   IF nAt>0
      oGrid:Set("CAM_LEN",aLen[nAt],.T.)
      oGrid:Set("CAM_DEC",0        ,.T.)
   ENDIF

   IF LEFT(oGrid:CAM_TYPE,1)="D"
      oGrid:Set("CAM_DEFAUL",PADR("&DPFECHA()",40),.T.)
      oGrid:Set("CAM_FORMAT",SPACE(40),.T.)
      ogrid:Set("CAM_UPDATE",,T.,.T.)
   ENDIF

   IF LEFT(oGrid:CAM_TYPE,1)="L"
      oGrid:Set("CAM_DEFAUL",PADR(".T.",40),.T.)
      oGrid:Set("CAM_FORMAT",SPACE(40),.T.)
      oGrid:Set("CAM_ZERO"  ,.F.,.T.)
   ENDIF

   
RETURN .T.

FUNCTION GRIDLOAD()
    LOCAL cName:="",nAt:=0

    IF oGrid:nOption=1

       cName:=SQLGET("DPCAMPOS","CAM_NAME","CAM_TABLE" +GetWhere("=",oDpTabla:TAB_NOMBRE))
       nAt  :=AT("_",cName)

       IF nAt>0
         cName:=PADR(LEFT(cName,nAt),LEN(cName))
         oGrid:Set("CAM_NAME",cName,.T.)
       ENDIF

    ENDIF


   oGrid:Set("CAM_FORMAT",PADR(oGrid:CAM_FORMAT,40),.T.)


RETURN  .T.

FUNCTION GRIDPOSTDELETE()
RETURN .T.

FUNCTION GRIDPREDELETE()
RETURN .T.

FUNCTION GRIDPRESAVE()

  IF oGrid:CAM_LEN=0 .AND. !LEFT(oGrid:CAM_TYPE,1)$"BM"
     MensajeErr("Campo "+oGrid:CAM_NAME+" no tiene Longitud")
     RETURN .F.
  ENDIF

  IF !oGrid:CAM_TYPE="N"
      oGrid:Set("CAM_DEC",0        ,.T.)
  ENDIF

  IF oGrid:CAM_TYPE="M"
      oGrid:Set("CAM_DEC",0        ,.T.)
      oGrid:Set("CAM_LEN",0        ,.T.)
  ENDIF

  oGrid:Set("CAM_NAME" ,UPPE(oGrid:CAM_NAME),.T.)
  oGrid:Set("CAM_ALTER",.T.)
  oGrid:Set("CAM_TABLE",oDpTabla:TAB_NOMBRE)

//? oGrid:CAM_FORMAT,"FORMAT"

RETURN .T.

FUNCTION SAYSTRUCT()

//   oGrid:oBrw:aCols[6]:cFooter:=LSTR(oGrid:GetTotal("CAM_LEN")+oGrid:GetTotal("CAM_DEC"))
//   oGrid:oBrw:aCols[1]:cFooter:=LSTR(LEN(oGrid:oBrw:aArrayData))
//   oGrid:oBrw:Refresh()
// ? oGrid:GetTotal("CAM_LEN"),oGrid:GetTotal("CAM_DEC")

RETURN .T.

FUNCTION GRIDPOSTSAVE()

   oGrid:SAYSTRUCT()

RETURN .T.

FUNCTION LOAD()
   LOCAL nAt

   IF oDpTabla:nOption=0
      oDpTabla:cWhere:=""  // Necesario Borra el Filtro
   ENDIF

   IF oDpTabla:nOption=1
      oDpTabla:TAB_NUMERO:=SQLINCREMENTAL("DPTABLAS","TAB_NUMERO")
   ENDIF

   nAt:=MAX(ASCAN(oDpTabla:aAplica,{|a,n| a[1]=oDpTabla:TAB_APLICA }),1)

   oDpTabla:oTAB_APLICA:Select(nAt)

   COMBOINI(oDpTabla:oTAB_DSN)

   oDpTabla:SAYSTRUCT()

RETURN .T.

FUNCTION PRESAVE()
  LOCAL cPrimary:=""

  oDpTabla:TAB_APLICA:=oDpTabla:aAplica[oDpTabla:oTAB_APLICA:nAt,1]
  oDpTabla:TAB_CONFIG:=!("<"$oDpTabla:TAB_DSN) // (oDpTabla:oTAB_DSN:nAt=1)
  oDpTabla:TAB_FECHA :=oDp:dFecha

  // 19/07/2014
  IF oDpTabla:nOption=1 .AND. ISFIELD("DPTABLAS","TAB_NUMERO") .OR. (Empty(oDpTabla:TAB_NUMERO) .AND. ISFIELD("DPTABLAS","TAB_NUMERO"))
    oDpTabla:TAB_NUMERO:=SQLINCREMENTAL("DPTABLAS","TAB_NUMERO")
  ENDIF

  cPrimary:=SQLGET("DPCAMPOS","CAM_COMMAN","CAM_TABLE" +GetWhere("=",oDpTabla:TAB_NOMBRE)+" AND "+;
                                           "CAM_COMMAN"+GetWhere(" LIKE ","%PRIMARY%"))

  IF !oDpTabla:VALPRIMARY()
    RETURN .F.
  ENDIF

RETURN .T.

FUNCTION POSTGRABAR()
   LOCAL cTable:=oDpTabla:TAB_NOMBRE,oTable,cSql,oDb:=OpenOdbc(oDp:cDsnConfig)
   LOCAL lDrop:=.T. // Si ejecuta DROP 

   oDp:aFieldLabel:={}

   oDpTabla:TAB_APLICA:=oDpTabla:aAplica[oDpTabla:oTAB_APLICA:nAt,1]
   oDpTabla:TAB_CONFIG:=!("<"$oDpTabla:TAB_DSN) // (oDpTabla:oTAB_DSN:nAt=1)
  
// IF oDpTabla:nOption<>1 .AND. oDpTabla:cNumero<>oDpTabla:TAB_NUMERO
//   SQLUPDATE("DPCAMPOS","CAM_TABLE" ,oDpTabla:TAB_TABLE ,"CAM_NUMTAB"+GetWhere("=",oDpTabla:cNumero))
// ENDIF

   IF oDpTabla:nOption<>1 .AND. !ALLTRIM(oDpTabla:TAB_NOMBRE_)==ALLTRIM(oDpTabla:TAB_NOMBRE)
     SQLUPDATE("DPCAMPOS"  ,"CAM_TABLE" ,oDpTabla:TAB_NOMBRE,"CAM_TABLE"+GetWhere("=",oDpTabla:TAB_NOMBRE_))
     SQLUPDATE("DPCAMPOSOP","OPC_TABLE" ,oDpTabla:TAB_NOMBRE,"OPC_TABLE"+GetWhere("=",oDpTabla:TAB_NOMBRE_))
   ENDIF

   IF !oDpTabla:nOption=1

      oTable:=OpenTable("SELECT * FROM DPTABLAS WHERE TAB_NOMBRE"+GetWhere("=",oDpTabla:TAB_NOMBRE),.T.)

      AEVAL(oTable:aFields,{|a,n| oTable:Replace(a[1],oDpTabla:Get(a[1])) })

      oTable:Commit(oTable:cWhere)
   ENDIF

   DPSETTIMER({||.T.},"DPGETTASK",100) 

   LOADTABLAS(.T.) 
   EJECUTAR("DBISTABLE",oDp:cDnsData,oDpTabla:TAB_NOMBRE,.T.)

//? "RECUERDA USAR EL DSN REAL"

   // Genera los Primary KEY Multiples
   EJECUTAR("DPTABLAPRIMARY",oDpTabla:TAB_NOMBRE)
   EJECUTAR("EJMIMPDATOS"   ,oDpTabla:TAB_NOMBRE,NIL,.T.)

   LOADTABLAS(.T.) // Inicializa y Recarga  la lista de las tablas

   oDp:aLogico:=NIL

   MyStruct()  // Hace release de los Datos

   IF oDpTabla:nOption=1 // Debe crear la Tabla de Datos

//      CheckTable(oDpTabla:TAB_NOMBRE,lDrop)

     EJECUTAR("DPCREATEFROMTXT",oDpTabla:TAB_NOMBRE)

   ELSEIF MsgNoYes("Actualiza Fisicamente la Tabla "+oDpTabla:TAB_NOMBRE,"Asegurese que no este Abierta") 

      EJECUTAR("DPCREATEFROMTXT",oDpTabla:TAB_NOMBRE)

      EJECUTAR("DPMYSQLTABLE",oDpTabla:TAB_NOMBRE,lDrop)

   ENDIF

   oDp:aDefault:={}

   EJECUTAR("SETTABLEDLEN",oDpTabla:TAB_NOMBRE) // Cambia la Estructura en las Demas Tablas Relaccionadas
   EJECUTAR("DPLOADPICTURE")
//   IFFRMWND("oDpTabla:oLbx","oDpTabla:oLbx:reload()")
//   IFFRMWND("oDpTabla:oLbx","oDpTabla:oLbx:oBrw:GoBottom()")

   EJECUTAR("GETDEFAULTALL") // oDp:aDefault

   EJECUTAR("DPTABLESTOZIP",oDpTabla:TAB_NOMBRE)
   EJECUTAR("SQLCREATETABLECODEDB","TAB_NOMBRE"+GetWhere("=",oDpTabla:TAB_NOMBRE))

  // 14/07/20236
  oDp:aTablas:={}
  cSql:=[ UPDATE DPTABLAS ]+;
        [ INNER JOIN dpcampos ON CAM_TABLE=TAB_NOMBRE ]+;
        [ SET TAB_PRIMAR=CAM_NAME ]+;
        [ WHERE CAM_COMMAN LIKE "%PRIMA%" ]

  oDb:EXECUTE(cSql)
 
  DPLBX("DPTABLAS",NIL,"TAB_NOMBRE"+GetWhere("=",oDpTabla:TAB_NOMBRE))

RETURN .T.

FUNCTION PRINTER()

   REPORTE("DPTABLAS")

RETURN .T.

/*
// Muestra los Campos
*/
FUNCTION LISTCAMPO()

   LOCAL cWhere:="CAM_TABLE"+GetWhere("=",oDpTabla:TAB_NOMBRE)
   LOCAL uValue,cCampo,nLen:=0
   LOCAL cTitle:="Campos de la Tabla "+oDpTabla:TAB_NOMBRE

   uValue:=oDpTabla:TAB_PRIMAR // Obtiene Actual de la Columna, Debe Sumarse
   nLen  :=LEN(uValue)
//   uValue:=IIF(EMPTY(uValue),"",alltrim(uValue)+",")

   cCampo:=EJECUTAR("REPBDLIST","DPCAMPOS",{"CAM_NAME","CAM_DESCRI","CAM_TYPE"},.F.,cWhere,cTitle)

   IF !Empty(cCampo)
      uValue:=DPCONCAT(ALLTRIM(uValue),",",cCampo)
      uValue:=PADR(uValue,nLen)
      uValue:=STRTRAN(uValue,",,","")    
      oDpTabla:SET("TAB_PRIMAR",uValue,.T.)
   ENDIF

RETURN .T.
/*
// Validar Campos del Indice
*/
FUNCTION VALPRIMARY()
   LOCAL aCampos,cNoExiste:="",I

   IF EMPTY(oDpTabla:TAB_PRIMAR)
      RETURN .T.
   ENDIF
  
   aCampos:=_VECTOR(oDpTabla:TAB_PRIMAR,",")

   FOR I=1 TO LEN(aCampos)

      IF EMPTY(SQLGET("DPCAMPOS","CAM_NAME","CAM_TABLE"+GetWhere("=",oDpTabla:TAB_NOMBRE)+;
                                       " AND CAM_NAME" +GetWhere("=",aCampos[I])))

        DPCONCAT(@cNoExiste,",",aCampos[I])

      ENDIF

   NEXT I

   IF !Empty(cNoExiste)
      MensajeErr("Campo(s) "+cNoExiste+CRLF+" no Existe","[Primary Key] Inválida")
      RETURN .F.
   ENDIF
 
RETURN .T.

FUNCTION VALZERO(lZero)
RETURN .T.

/*
// Debe Crear el Formato
*/
FUNCTION VALMILES(lMiles)
   LOCAL cPicture:=BuildPicture(oGrid:CAM_LEN,oGrid:CAM_DEC,lMiles)

   IF oGrid:CAM_TYPE="N" .AND. Empty(oGrid:CAM_FORMAT)
     oGrid:SET("CAM_FORMAT",PADR(cPicture,40),.T.)
   ENDIF

RETURN .T.
// Valida Decimales
FUNCTION VALCAMDEC()
  LOCAL lMiles:=oGrid:CAM_MILES
  LOCAL cPicture:=""

  IF !oGrid:CAM_TYPE="N"
     RETURN .T.
  ENDIF

  IF oGrid:CAM_DEC>7
     MensajeErr("Cantidad Decimal no puede ser Superior a Siete")
     RETURN .T.
  ENDIF

  IF oGrid:CAM_LEN-oGrid:CAM_DEC<=1
     MensajeErr("Cantidad Decimal no puede ser Superior a la fracción Entera")
     RETURN .T.
  ENDIF

  IF oGrid:CAM_LEN>3
     lMiles:=.T.
  ELSE
     lMiles:=.F
  ENDIF

  cPicture:=BuildPicture(oGrid:CAM_LEN,oGrid:CAM_DEC,lMiles)
  oGrid:SET("CAM_MILES",.T.,.T.)
  IF Empty(oGrid:CAM_FORMAT)
    oGrid:SET("CAM_FORMAT",PADR(cPicture,40),.T.)
  ENDIF

RETURN .T.

FUNCTION CAMLEN()
  
    IF oGrid:CAM_TYPE="C" .AND. oGrid:CAM_LEN>250
       MensajeErr("Campo Caracter no puede superar 250 Caracteres")
       RETURN .F.
    ENDIF

    IF oGrid:CAM_TYPE="N" .AND. oGrid:CAM_LEN>19
       MensajeErr("Campo Numérico no puede superar 19 Enteros")
       RETURN .F.
    ENDIF

    IF LEFT(oGrid:CAM_TYPE,1)="C" .AND. oGrid:CAM_LEN=8 .AND. "HORA"$oGrid:CAM_NAME
      oGrid:Set("CAM_DEFAUL",PADR("&DPHORA()",40),.T.)
      ogrid:Set("CAM_UPDATE",,T.,.T.)
    ENDIF

RETURN .T.

FUNCTION VALNOMBRE()

  IF Empty(oDpTabla:TAB_NOMBRE)
     MensajeErr("Es necesario indicar Nombre de la Tabla")
     RETURN .F.
  ENDIF


  IF oDpTabla:nOption=3 .AND. !(ALLTRIM(oDpTabla:cNombre_)==ALLTRIM(oDpTabla:TAB_NOMBRE))

    SQLUPDATE("DPTABLAS","TAB_NOMBRE",oDpTabla:TAB_NOMBRE,"TAB_NOMBRE"+GetWhere("=",oDpTabla:cNombre_))
    SQLUPDATE("DPCAMPOS","CAM_TABLE" ,oDpTabla:TAB_NOMBRE,"CAM_TABLE" +GetWhere("=",oDpTabla:cNombre_))

    oDpTabla:cNombre_:=oDpTabla:TAB_NOMBRE
      
  ENDIF
  

RETURN .T.

FUNCTION SET_PRIMARYKEY()
  LOCAL cPrimary:=SQLGET("DPCAMPOS","CAM_NAME","CAM_TABLE"+GetWhere("=",oDpTabla:cNombre_)+" AND CAM_COMMAN"+GetWhere(" LIKE ","%PRIMARY%"))

  IF !Empty(cPrimary)
     MensajeErr("Tabla ya Posee Clave Primaria en Campo "+cPrimary)
     RETURN .F.
  ENDIF

  oGrid:Set("CAM_COMMAN","PRIMARY KEY NOT NULL",.T.)

  IF oGrid:nOption=3
     oGrid:Save()
  ENDIF

RETURN .T.

/*
// Comando, INCREMENTAL Debe incluir primary  KEY
*/
FUNCTION CAMCOMMAN(cCmd)
  
  IF "AUTO_INCREMENT"$cCmd .AND. !"PRIMARY KEY"$cCmd
     MsgMemo("AUTO_INCREMENT, Requiere PRIMARY KEY")
     oGrid:SET("CAM_COMMAN",ALLTRIM(cCmd)+" PRIMARY KEY ",.T.)
  ENDIF

RETURN .T.

/*
// Dialogo en Posición de Browse
*/
FUNCTION DLGBRW()
    LOCAL oBrw:=oGrid:oBrw
    LOCAL oDlg,oEditLbx:=ErrorSys(.T.)
    LOCAL oCol    := oBrw:aCols[oBrw:nColSel]
    LOCAL nRow    := ( ( oBrw:nRowSel - 1 ) * oBrw:nRowHeight ) + oBrw:HeaderHeight() + 2
    LOCAL nCol    := oCol:nDisplayCol + 3
    LOCAL nWidth  := oCol:nWidth - 4
    LOCAL nHeight := oCol:oBrw:nRowHeight - 4
    LOcal aPoint  := { nRow, nCol }
    LOCAL nSel    :=1,cLista:=oGrid:CAM_COMMAN
//  LOCAL aPoint  :={} // EJECUTAR("GETAPOINT",oGrid:oBrw)
    LOCAL aLista  :={}
    LOCAL cTitle  :="Atributo del Campo "+oGrid:CAM_NAME,lOk:=.F.

    AADD(aLista,"PRIMARY KEY")
    AADD(aLista,"AUTO_INCREMENT PRIMARY KEY")
    AADD(aLista,"UNSIGNED ZEROFILL AUTO_INCREMENT PRIMARY KEY")
    AADD(aLista,"PRIMARY KEY NOT NULL")
    AADD(aLista,"NOT NULL")

    aPoint:= ClientToScreen( oBrw:hWnd, aPoint )

    DEFINE DIALOG oDlg OF oBrw:oWnd TITLE cTitle

    oDlg:lHelpIcon:=.F.

    @ 0, 0 LISTBOX oEditLbx VAR nSel OF oDlg SIZE 0,0 ITEMS aLista

    oEditLbx:SetColor(oDp:Get_nCltText,oDp:Get_nClrPane)

    oEditLbx:bLButtonUp := {||  lOk:=.T.,cLista:=aLista[nSel],oDlg:End()}

    ACTIVATE DIALOG oDlg ON INIT (oDlg:Move( aPoint[ 1 ]+nHeight, aPoint[ 2 ]-5 ,240,100 ),;
                                  oEditLbx:Move(0,0,330,80,.T.))

    IF lOk
       cLista:=aLista[nSel]
    ENDIF

RETURN cLista



// EOF

