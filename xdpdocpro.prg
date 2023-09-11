// Programa   : DPDOCPRO
// Fecha/Hora : 22/11/2004 23:10:42
// Prop¢sito  : Factura de Venta
// Creado Por : Juan Navas
// Llamado por: Ventas y Cuentas por Cobrar
// Aplicaci¢n : COMPRAS
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"
#include "Constant.ch"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cTipDoc)
  LOCAL I,aData:={},oGrid,oCol,cSql,cScope,aMonedas:={},T1:=SECONDS()
  LOCAL cTitle:="",cExcluye:="",cScope
  LOCAL oFont,oFontG,oFontB,oSayRef

  DEFAULT cTipDoc:="FAC"

  EJECUTAR("DPPRIVCOMLEE",cTipDoc,.F.) // Lee los Privilegios del Usuario

  cTitle:=oDp:Get(cTipDoc+"Titulo")

  // Font Para el Browse
  DEFINE FONT oFont  NAME "Times New Roman"   SIZE 0, -12
  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -12 BOLD

  DOCENC(cTitle,"oDocPro","DPDOCPRO"+cTipDoc+".EDT")

  cScope:="DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+;
          " AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
          " AND DOC_DOCORG='C' AND DOC_TIPTRA='D' "

  oDocPro:lBar:=.T.
  oDocPro:SetScope(cScope)
  oDocPro:SetTable("DPDOCPRO","DOC_CODIGO,DOC_NUMERO")
  oDocPro:cWhereRecord:=cScope
  oDocPro:cNomDoc    :=ALLTRIM(cTitle)
  oDocPro:nBruto     :=0
  oDocPro:nIVA       :=0
  oDocPro:lDocGen    :=.F.
//oDocPro:_CODIGO    :=""

  EJECUTAR("DPDOCPROPAR",oDoc,cTipDoc)

  IF (!FILE("FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT")) .AND. oDocPro:lPar_LibCom
     COPY FILE "FORMS\DPDOCPROFAC.EDT" TO "FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT"
  ENDIF

  IF (!FILE("FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT")) .AND. !oDocPro:lPar_LibCom
     COPY FILE "FORMS\DPDOCPRONRC.EDT" TO "FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT"
  ENDIF


// ? oDocPro:cPrimary
  oDocPro:cPrimary   :="DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO"

//oDocPro:lPar_EditNum:=.T. // Editable

  oDocPro:Windows(0,0,445,798)

//  IF !oDocPro:lPar_LibCom // No es Documento Fiscal

  IF !oDocPro:lPar_EditNum
    oDocPro:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO"
    oDocPro:SetIncremental("DOC_NUMERO",cScope,oDp:Get(cTipDoc+"NUMERO"))
  ENDIF
 
  oDocPro:SetMemo("DOC_NUMMEM","Descripción Amplia")
  oDocPro:AddBtnEdit("xpeople2.bmp","Cliente Gen‚rico","(oDocPro:nOption=1 .OR. oDocPro:nOption=3) .AND. oDocPro:DOC_CODIGO=STRZERO(0,10)",;
                                     "EJECUTAR('DPCLIENTESCERO',oDoc,oDocPro:oDOC_CODIGO)",;
                                     "CLI")

  oDocPro:AddBtn("xexpediente.bmp","Expedientes","(oDocPro:nOption=0)",;
                 "EJECUTAR('DPDOCCLIEXP',NIL,oDocPro:DOC_CODSUC,;
                                             oDocPro:DOC_TIPDOC,;
                                             oDocPro:DOC_CODIGO,;
                                             oDocPro:DOC_NUMERO,;
                                             'Expedientes '+oDocPro:cTitle)",;
                    "CLI")


  oDocPro:AddBtn("MENU.bmp","Menú de Opciones","(oDocPro:nOption=0)",;
                    "EJECUTAR('DPDOCPROMNU',oDocPro:DOC_CODSUC ,;
                                            oDocPro:DOC_NUMERO ,;
                                            oDocPro:DOC_CODIGO ,;
                                            oDocPro:cNomDoc , oDocPro:DOC_TIPDOC , oDoc  )","CLI")



   IF oDp:Get(cTipDoc+"RETISR")

     oDocPro:AddBtn("RETISLR.bmp","Retención ISLR","(oDocPro:nOption=0)",;
                     "EJECUTAR('DPDOCPROISLR',oDocPro:DOC_CODSUC,;
                                              oDocPro:DOC_TIPDOC,;
                                              oDocPro:DOC_CODIGO,;
                                              oDocPro:DOC_NUMERO,;
                                              oDocPro:cNomDoc , 'C'    )",;
                                              "CLI")

   ENDIF

   IF oDp:Get(cTipDoc+"RETIVA")

     oDocPro:AddBtn("RETIVA.bmp","Retención de IVA","(oDocPro:nOption=0)",;
                     "EJECUTAR('DPDOCPRORTI' ,oDocPro:DOC_CODSUC,;
                                              oDocPro:DOC_TIPDOC,;
                                              oDocPro:DOC_CODIGO,;
                                              oDocPro:DOC_NUMERO,;
                                              oDocPro:cNomDoc , 'C'    )",;
                                             "PRO")

   ENDIF

  IF oDp:Get(cTipDoc+"PAGOS") .AND. .F.

    oDocPro:AddBtn("EFECTIVO.bmp","Recepci¢n de Pagos","(oDocPro:nOption=0)",;
                  "EJECUTAR('DPDOCCLIPAG',oDocPro:DOC_CODSUC,;
                                          oDocPro:DOC_TIPDOC,;
                                          oDocPro:DOC_CODIGO,;
                                          oDocPro:DOC_NUMERO,;
                                          oDocPro:cNomDoc   ,;
                                          oDocPro:DOC_CXP   )",;
                                          "CLI")

 
  ENDIF
/*
  @ 14,40 BUTTON  oDocPro:oTotal PROMPT " Totalizar " ACTION;
                  EJECUTAR("DOCTOTAL",{oDocPro:DOC_TIPDOC,;
                                       oDocPro:DOC_CODSUC,;
                                       oDocPro:DOC_NUMERO,;
                                       oDocPro:DOC_CODIGO,;
                                       oDocPro:cNomDoc},.T.,NIL,NIL,.F.);
                  WHEN oDocPro:DOC_NETO>0 .AND. oDocPro:nOption>0
*/

  @ 1.35, 0 FOLDER oDocPro:oFolder ITEMS cTitle,"Otros Valores";
                OF oDocPro:oDlg SIZE 390,61

  SETFOLDER( 1)

  @ 0.1,.1 SAY oSayRef PROMPT;
           oDocPro:cNamePro+":" RIGHT SIZE 42,20

//  oSayRef:bAction:={||oDocPro:CONPROVEEDOR()}

  SayAction(oSayRef,{||oDocPro:CONPROVEEDOR()})


  @ 1.5,.1 SAY oSayRef PROMPT;
           oDocPro:cNameMon+":" RIGHT SIZE 42,20

  SayAction(oSayRef,{||DpLbx("DPTABMON.LBX")})

// oSayRef:bAction:={||DpLbx("DPTABMON.LBX")}
// SayAction(

  @ 1.0,0 SAY oSayRef PROMPT "Descuento:";
          SIZE 42,12;
          FONT oFontB;
          RIGHT;
          COLORS CLR_HBLUE,oDp:nGris

//  oSayRef:bAction:={||oDocPro:RUNDESC()}

  SayAction(oSayRef,{||oDocPro:RUNDESC()})

  @ 2.2,10 SAY "Condición:"        RIGHT SIZE 42,20
  @ 2.2,28 SAY "Plazo:"            RIGHT SIZE 42,20

  @ 0.1,50 SAY "Número:"   RIGHT
  @ 0.8,50 SAY "Fecha:"    RIGHT
  @ 1.5,50 SAY "Estado:"   RIGHT
  @ 1.5,20 SAY "Cambio:"   RIGHT


  @ .1,06 BMPGET oDocPro:oDOC_CODIGO VAR oDocPro:DOC_CODIGO;
                 VALID CERO(oDocPro:DOC_CODIGO,NIL,.T.) .AND.;
                 oDocPro:SeekTable("DPPROVEEDOR",oDocPro:oDOC_CODIGO,"PRO_CODIGO",NIL,"PRO_NOMBRE",oDocPro:oProNombre);
                 .AND. EJECUTAR("DPDOCPROVALPRO",oDocPro:oDOC_CODIGO,oDoc);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPPROVEEDOR",NIL,"PRO_SITUAC='A' OR PRO_SITUAC='C'"),;
                         oDpLbx:GetValue("PRO_CODIGO",oDocPro:oDOC_CODIGO)); 
                 WHEN (AccessField("DPDOCPRO","DOC_CODIGO",oDocPro:nOption);
                      .AND. oDocPro:nOption!=0;
                      .AND. oDocPro:lEditPro  ;
                      .AND. IIF(oDocPro:nOption=3 .AND. !oDocPro:lPar_CamCodPro,.F.,.T.));
                SIZE 48,10

  //
  // Campo : DOC_CODMON
  // Uso   : Moneda                                  
  //
  @ 1.6, 06.0 COMBOBOX oDocPro:oDOC_CODMON VAR oDocPro:DOC_CODMON ITEMS oDp:aMonedas;
                      VALID EJECUTAR("DPDOCPROVALMON",oDoc);
                      WHEN (AccessField("DPDOCPRO","DOC_CODMON",oDocPro:nOption);
                     .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_SelMon) SIZE 100,NIL

  ComboIni(oDocPro:oDOC_CODMON)

 @ 2.6,6  GET oDocPro:oDOC_VALCAM VAR oDocPro:DOC_VALCAM;
          PICTURE oDp:cPictValCam;
          VALID MensajeErr("Valor Debe ser Diferente que 0.00","Valor Inválido",{||oDocPro:DOC_VALCAM<>0});
          WHEN (AccessField("DPDOCPRO","DOC_VALCAM",oDocPro:nOption);
               .AND. oDocPro:nOption!=0.AND. oDocPro:nPar_Desc>0);
               .AND. !(LEFT(oDocPro:DOC_CODMON,3)=oDp:cMoneda);
          SIZE 20,10 RIGHT

// ANTES          VALID EJECUTAR("DPDOCPROVALCAM",oDocPro:DOC_VALCAM,oDoc);


 @ 2.6,6  GET oDocPro:oDOC_DCTO VAR oDocPro:DOC_DCTO;
          PICTURE "999.99";
          VALID EJECUTAR("DPDOCCLIVALDES",oDocPro:DOC_DCTO,oDoc);
          WHEN (AccessField("DPDOCPRO","DOC_DCTO",oDocPro:nOption);
               .AND. oDocPro:nOption!=0.AND. oDocPro:nPar_Desc>0 .AND. EMPTY(oDocPro:DOC_DESCCO));
          SIZE 20,10 RIGHT


 @ 2.6,13  GET oDocPro:oDOC_CONDIC VAR oDocPro:DOC_CONDIC;
           VALID .T.;
           WHEN (AccessField("DPDOCPRO","DOC_CONDIC",oDocPro:nOption);
               .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_Cond);
           SIZE 80,10 

 @ 2.6,26.5 GET oDocPro:oDOC_PLAZO  VAR oDocPro:DOC_PLAZO;
           PICT "999";
           VALID MensajeErr("Plazo no Permitido",NIL,{||oDocPro:DOC_PLAZO<=oDocPro:nPar_MaxDias});
           WHEN (AccessField("DPDOCPRO","DOC_PLAZO",oDocPro:nOption);
               .AND. oDocPro:nOption!=0 .AND. oDocPro:nPar_MaxDias>0);
           SIZE 18,10 RIGHT

 @ 0.0,17 SAY oDocPro:oProNombre;
          PROMPT MYSQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))

 @ 0.0,43 GET oDocPro:oDOC_NUMERO VAR oDocPro:DOC_NUMERO;
          VALID CERO(oDocPro:DOC_NUMERO) .AND. oDocPro:VALNUMERO();
          WHEN (AccessField("DPDOCPRO","DOC_NUMERO",oDocPro:nOption);
              .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_EditNum);
          SIZE 35,10

  @ 0.9,43 BMPGET oDocPro:oDOC_FECHA  VAR oDocPro:DOC_FECHA  PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oDocPro:oDOC_FECHA ,oDocPro:DOC_FECHA);
           VALID (EJECUTAR("DPVALFECHA",oDocPro:DOC_FECHA,.T.,.T.) .AND. ;
                  EJECUTAR("DPDOCCLIVALCAM",oDoc));
            WHEN (AccessField("DPDOCMOV","DOC_FECHA",oDocPro:nOption);
                .AND. oDocPro:nOption!=0.AND. oDocPro:lPar_Fecha);
           SIZE 41,10

 // Solo Documentos Fiscales

 IF oDocPro:lPar_LibCom // S¢lo Documento Fiscal

   @ 0.0,43 GET oDocPro:oDOC_NUMFIS VAR oDocPro:DOC_NUMFIS;
            VALID CERO(oDocPro:DOC_NUMFIS);
            WHEN (AccessField("DPDOCPRO","DOC_NUMFIS",oDocPro:nOption);
               .AND. oDocPro:nOption!=0);
            SIZE 35,10

 ENDIF

 @ 1.5,57 SAY oDocPro:oEstado PROMPT EJECUTAR("DPDOCPROEDO",oDocPro:DOC_CODSUC,oDocPro:cTipDoc,oDocPro:DOC_CODIGO,;
                                  oDocPro:DOC_NUMERO,;
                                  NIL,oDocPro:DOC_CXP,oDocPro:DOC_NETO,oDoc)



// @ 1 ,1  SAY "Origen:" RIGHT

 IF oDocPro:lPar_LibCom // S¢lo Documento Fiscal
   @ 0.1,50 SAY "#Fiscal:" RIGHT
 ENDIF


 SETFOLDER( 2)

 oDocPro:oScroll:=oDocPro:SCROLLGET("DPDOCPRO","DPDOCPRO"+cTipDoc+".SCG",cExcluye)

 IF oDocPro:IsDef("oScroll")
    oDocPro:oScroll:SetEdit(.F.)
 ENDIF

 oDocPro:oScroll:SetColorHead(16384 ,11266812,oFontB) 
 oDocPro:oScroll:SetColSize(200,250,290)
 oDocPro:oScroll:SetColor(14612478,CLR_GREEN,1,15399935,oFontB) 
 oDocPro:oScroll:SetColor(14612478,0,2,15399935,oFont) 
 oDocPro:oScroll:SetColor(14612478,0,3,15399935,oFontB)


 SETFOLDER( 0)

 @ 00,50 SAY oDocPro:oProducto PROMPT SPACE(40)
 @ 1, 1.0 GROUP oDocPro:oGroup TO 10,10 

 @ 12,50 SAY oDocPro:oNeto     PROMPT TRAN(oDocPro:DOC_NETO,"99,999,999,999.99") RIGHT

 @ 1,1 SAY "I.V.A.:";
       RIGHT;
       SIZE 42,12

 @ 12,50 SAY oDocPro:oIVA      PROMPT TRAN(oDocPro:nIva  ,"99,999,999,999.99") RIGHT

 @ 14,0 SAY oSayRef PROMPT "Neto:";
        RIGHT;
        SIZE 42,12;
        FONT oFontB;
        RIGHT

 SayAction(oSayRef,{||oDocPro:TOTALIZAR()})

 // ;    COLORS CLR_HBLUE,oDp:nGris
 // oSayRef:bAction:={||oDocPro:TOTALIZAR()}

  cSql :=" SELECT "+SELECTFROM("DPMOVINV",.F.)+;
         " ,IF(MOV_NUMMEM>0 AND MEM_DESCRI<>'',MEM_DESCRI,INV_DESCRI) AS INV_DESCRI "+;
         " FROM DPMOVINV "+;
         " INNER JOIN DPINV     ON MOV_CODIGO=INV_CODIGO "+;
         " LEFT  JOIN DPMEMO    ON MOV_NUMMEM=MEM_NUMERO "

  cScope:="MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND MOV_APLORG='C' AND MOV_INVACT=1"

  oGrid:=oDocPro:GridEdit( "DPMOVINV" ,"DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO" , "MOV_CODSUC,MOV_TIPDOC,MOV_CODCTA,MOV_DOCUME" , cSql , cScope ) 

  oGrid:cScript    :="DPDOCPRO"
  oGrid:aSize      :={140+21,0,790,190-26}

  oGrid:nClrPane2:=14612478
  oGrid:nClrPane1:=15399935

  oGrid:oFont      :=oFont
  oGrid:oFontH     :=oFontB
  oGrid:bWhen      :="!EMPTY(oDocPro:DOC_CODIGO).AND.!EMPTY(oDocPro:DOC_NUMERO)"
  oGrid:bValid     :="!EMPTY(oDocPro:DOC_NUMERO)"
  oGrid:cItem      :="MOV_ITEM"
  oGrid:cLoad      :="GRIDLOAD"
  oGrid:cPresave   :="GRIDPRESAVE"
  oGrid:cPostSave  :="GRIDPOSTSAVE" 
  oGrid:cPreDelete :="GRIDPREDELETE"
  oGrid:cPostDelete:="GRIDPOSTDELETE" 
  oGrid:SetMemo("MOV_NUMMEM","Descripción Amplia",1,1,100,200)
  oGrid:lTallas     :=.F.
  oGrid:cTallas     :=""
  oGrid:lTotal      :=.T.
  oGrid:aComponentes:={}

  oGrid:nLotes      :=0 // Cantidad del Lote
  oGrid:nCostoLote  :=0 // Costo de Lotes
  oGrid:nPrecioLote :=0 // Precio del Lote

//  IF cTipDoc<>"CTZ"
//    oGrid:AddBtn("IMPORTAR.BMP","Importar","oGrid:nOption=1",;
//                 [EJECUTAR("DPDOCPROMNUIMP],oGrid:MOV_CODALM,oDocPro:DOC_CODSUC,oDocPro:DOC_CODIGO,oGrid)],"IMP")

   oGrid:AddBtn("IMPORTAR.BMP","Importar","oGrid:nOption=1",;
                 [EJECUTAR("DPDOCPROMNUIMP",oDoc)],"IMP")

   oGrid:AddBtn("GRUPOS2.BMP","Grupos","oGrid:nOption=1",;
                 [EJECUTAR("GRIDGRUPOS",oGrid)],"GRU")

   oGrid:AddBtn("MARCA2.BMP","Marcas","oGrid:nOption=1",;
                 [EJECUTAR("GRIDMARCAS",oGrid)],"MAR")

   oGrid:AddBtn("FIND22.BMP","Buscar","oGrid:nOption=1",;
                 [EJECUTAR("GRIDBUSCAINV",oGrid)],"BUS")

//  ENDIF

  oGrid:cMetodo     :="P"
  oGrid:cAlmacen    :=""
  oGrid:bChange     :='oDocPro:oProducto:SetText(oDocPro:cNameInv+": "+oGrid:INV_DESCRI)'
  oGrid:nMaxDesc    :=0 // Descuento M ximo Seg£n Precios de Venta
  oGrid:cInvDescri  :=SPACE(40)
  oDp:oGrid         :=oGrid
  oGrid:nClrPaneH   := 11266812 // 4511739
  oGrid:nRecSelColor:= 11266812 // 4511739

  // 16384 ,11266812,oFontB

  // Almacen
  IF oDocPro:lPar_Almace .AND. oDocPro:lPar_DocAlm .AND. oDp:nAlmacen>1
    oCol:=oGrid:AddCol("MOV_CODALM")
    oCol:cTitle   :="Alm."
    oCol:bValid   :={||oGrid:VMOV_CODALM(oGrid:MOV_CODALM)}
    oCol:cMsgValid:="Almacén no Existe"
    oCol:nWidth   :=33+5
    oCol:cListBox :="DPALMACEN.LBX"
    oCol:nEditType:=EDIT_GET_BUTTON
  ENDIF

 // Campo C¢digo
  oCol:=oGrid:AddCol("MOV_CODIGO")
  oCol:cTitle   :="Código"
  oCol:bValid   :={||oGrid:VMOV_CODIGO(oGrid:MOV_CODIGO)}
  oCol:cMsgValid:="Producto no Existe"
  oCol:nWidth   :=125
  oCol:cListBox :="DPINV.LBX"

  IF UPPE(LEFT(oDp:cTipPer,3))="GOB"
    oCol:cListBox :="DPINVGRU.LBX"
  Endif

  oCol:bPostEdit:='oGrid:ColCalc("INV_DESCRI")' 
  oCol:nEditType:=EDIT_GET_BUTTON

  // Descripci¢n
  oCol:=oGrid:AddCol("INV_DESCRI")
  oCol:cTitle:="Descripción"
//oCol:bCalc :={||SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))}
  oCol:bCalc :={||oGrid:cInvDescri}
  oCol:bWhen :=".F."
  oCol:nWidth:=207+IIF(oDocPro:lPar_Almace .AND. oDocPro:lPar_DocAlm .AND. oDp:nAlmacen>1 ,-5 , 34)+IIF(oDocPro:nPar_ItemDesc >0 , 0, 30)
  oCol:bValid    :={||oGrid:VINV_DESCRI(oGrid:INV_DESCRI)}


 // Unidad de Medida
  oCol:=oGrid:AddCol("MOV_UNDMED")
  oCol:cTitle    :="Medida"
  oCol:nWidth    :=60
  oCol:aItems    :={||oGrid:BuildUndMed(.T.)}
  oCol:aItemsData:={||oGrid:BuildUndMed(.F.)}
  oCol:bValid    :={||oGrid:VMOV_UNDMED(oGrid:MOV_UNDMED)}
  oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO) .AND. oGrid:cMetodo<>'S' .AND. !oGrid:lTallas"
    oCol:bPostEdit:={|| oGrid:SET("MOV_UNDMED" , oGrid:MOV_UNDMED ,.T.) } 


  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle   :="Cantidad"

  IF oDocPro:nPar_InvFis<>0
    oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO) .AND. oGrid:cMetodo<>'S' .AND. !oGrid:lTallas"
  ELSE
    oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas"
  ENDIF

  oCol:bValid   :={||oGrid:VMOV_CANTID()}
  oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
  oCol:cPicture := oDp:cPictCanUnd  // FIELDPICTURE("DPMOVINV","MOV_CANTID",.T.)
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
  oCol:nWidth:=70-5

  oCol:=oGrid:AddCol("MOV_COSTO")
  oCol:cTitle   :="Costo"
  oCol:bWhen    :="!EMPTY(oGrid:MOV_CANTID) .AND. oDocPro:lPar_Precio .AND. oGrid:nCostoLote=0"
  oCol:bValid   :="oGrid:VMOV_COSTO()"
  oCol:cPicture :=oDp:cPictCosto
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
  oCol:nWidth   :=80+15

  IF  oDp:cModeloPos="Farmacia"

  IF oDocPro:nPar_ItemDesc >=0
     oCol:=oGrid:AddCol("MOV_DESCUE")
     oCol:cTitle   :="%D."
     oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO).AND. oDocPro:nPar_ItemDesc>0"
     oCol:bValid   :={||oGrid:VMOV_DESCUE()}
     oCol:cMsgValid:="Descuento Debe ser Positivo"
     oCol:cPicture :="999.99"
     oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
     oCol:nWidth:=50
     oCol:cListBox :={||oGrid:DESC_CASC(oGRID:MOV_CANTID*oGRID:MOV_COSTO)}
     oCol:nEditType:=EDIT_GET_BUTTON
  ENDIF

 ELSE


  IF oDocPro:nPar_ItemDesc >0
     oCol:=oGrid:AddCol("MOV_DESCUE")
     oCol:cTitle   :="%D."
     oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO).AND. oDocPro:nPar_ItemDesc>0"
     oCol:bValid   :={||oGrid:VMOV_DESCUE()}
     oCol:cMsgValid:="Descuento Debe ser Positivo"
     oCol:cPicture :="999.99"
     oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
     oCol:nWidth:=40
  ENDIF

ENDIF

  oCol:=oGrid:AddCol("MOV_TOTAL")
  oCol:cTitle   :="Total"
  oCol:cPicture :=oDp:cPictTotRen // FIELDPICTURE("DPMOVINV","MOV_TOTAL",.T.)
  oCol:bCalc    :={|nTotal|nTotal:=oGRID:MOV_CANTID*oGRID:MOV_COSTO,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}
  oCol:bWhen    :={||oDocPro:lPar_TotRen .AND. !EMPTY(oGrid:MOV_COSTO)}
  oCol:lTotal   :=.T.
  oCol:nWidth   :=100 + IIF(oDocPro:nPar_ItemDesc >0 , 0, 12 )
  oCol:bValid   :={||oGrid:VMOV_TOTAL(oGrid:MOV_TOTAL)}

  oGrid:oSayOpc   :=oDocPro:oProducto

//  @ 14,40 BUTTON  oDocPro:oTotal PROMPT " Total " ACTION EJECUTAR("DOCTOTAL",oDoc,.T.);
//                  WHEN oDocPro:DOC_NETO>0 .AND. oDocPro:nOption>0

  oDocPro:Activate({||oDocPro:DOCPROINI()})

RETURN .T.

FUNCTION DOCPROINI()

  LOCAL nClrBlink := CLR_YELLOW   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL oFontB

  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -14 BOLD

  @360, 1 STSAY oDocPro:oSayMsgErr PROMPT oDocPro:cSayMsgErr  OF oDocPro:oDlg PIXEL ;
          COLORS CLR_HRED SIZE 250, 19 FONT oFontB ;
          SHADED;
          BLINK nClrBlink, nInterval, nStop  

 oDocPro:oScroll:oBrw:Gotop()

 oDocPro:oSayMsgErr:Hide()

RETURN .T.

FUNCTION PREDELETE(oForm,lDelete)
RETURN EJECUTAR("DPDOCPROPREDEL",oForm,lDelete)

/*
// PosBorrar
*/
//FUNCTION POSTDELETE()
//RETURN EJECUTAR("DPDOCPROPOSDEL",oDoc)


/*
// Cancelar
*/
FUNCTION CANCEL()
RETURN EJECUTAR("DPDOCCLICANCEL",oDoc)

/*
// Carga los Datos
*/
FUNCTION LOAD()
RETURN EJECUTAR("DPDOCPROLOAD",oDoc)

FUNCTION POSTGRABAR()
RETURN EJECUTAR("DPDOCPROPOSGRA",oDoc)

FUNCTION GRIDLOAD()
RETURN EJECUTAR("VTAGRIDLOAD",oGrid)

/*
// Pregrabar
*/
FUNCTION GRIDPRESAVE()
RETURN EJECUTAR("COMGRIDPRESAVE",oGrid)

/*
// Grabaci¢n del Item
*/
FUNCTION GRIDPOSTSAVE()
RETURN EJECUTAR("VTAGRIDPOSSAV",oGrid)

/*
// Ejecuci¢n Antes de Eliminar el Item
*/
FUNCTION GRIDPREDELETE()
RETURN EJECUTAR("VTAGRIDPREDEL",oGrid)

/*
// PostGrabar
*/
FUNCTION GRIDPOSTDELETE()
RETURN EJECUTAR("VTAGRIDPOSDEL",oGrid)

/*
// C¢digo de Almacen
*/
FUNCTION VMOV_CODALM(cCodAlm)
RETURN EJECUTAR("VTAGRIDVALALM",oGrid)

/*
// Valida C¢digo del Producto
*/
FUNCTION VMOV_CODIGO(cCodInv)
RETURN  EJECUTAR("COMGRIDVALCOD",oGrid)

/*
// Valida Descripci¢n del Producto
*/
FUNCTION VINV_DESCRI(cCodInv)
RETURN  EJECUTAR("VTAGRIDVALTEX",oGrid)

/*
// Unidad de Medida
*/
FUNCTION VMOV_UNDMED(cUndMed)
RETURN EJECUTAR("VTAGRIDVALUND",oGrid)

/*
// Valida Cantidad
*/
FUNCTION VMOV_CANTID()
RETURN EJECUTAR("VTAGRIDVALCAN",oGrid)

/*
// Valida Descuento
*/
FUNCTION VMOV_COSTO()
RETURN EJECUTAR("COMGRIVALCOS",oGrid)

/*
// Descuento en Cascada
*/
FUNCTION DESC_CASC(nBase)
EJECUTAR("DPDOCDESCITEM",oDocPro,nBase,oDocPro:DOC_DESCCO,!oDocPro:nOption=0)
RETURN 


/*
// Valida Descuento
*/
FUNCTION VMOV_DESCUE()
RETURN EJECUTAR("VTAGRIDVALDES",oGrid)

/*
// Valida Descuento
*/
FUNCTION VMOV_TOTAL()
RETURN EJECUTAR("VTAGRIDVALTOT",oGrid)


/*
// Construye las Opciones
*/
FUNCTION BuildUndMed(lData)
  LOCAL aItem:={}

  aItem:=EJECUTAR("INVGETUNDMED",oGrid:MOV_CODIGO,NIL,NIL,oGrid)

  IF (EMPTY(oGrid:MOV_UNDMED).AND.!Empty(aItem)) .OR. LEN(aItem)=1
     oGrid:Set("MOV_UNDMED",aItem[1],.T.)
  ENDIF

RETURN aItem

/*
// Realiza el Trabajo de Depuraci¢n
*/
FUNCTION DOCMOVDEPURA()
RETURN .T.

/*
// Debe Generar el N£mero del Documento
*/
FUNCTION BUILDNUMDOC()
RETURN .T.

FUNCTION PRINTER()

  oDp:cDocNumIni:=oDocPro:DOC_NUMERO
  oDp:cDocNumFin:=oDocPro:DOC_NUMERO


  oDp:cDocCodIni:=oDocPro:DOC_CODIGO
  oDp:cDocCodFin:=oDocPro:DOC_CODIGO

  REPORTE("DOCPRO"+oDocPro:DOC_TIPDOC,"DOC_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC))
  oDp:oGenRep:aCargo:=oDocPro:DOC_TIPDOC

RETURN .T.

/*
// Consulta del Documento
*/
FUNCTION VIEW()
   EJECUTAR("DPDOCPRO"+oDocPro:cTipDoc+"CON",oDoc)
RETURN 

FUNCTION PREGRABAR(oForm,lSave)
RETURN EJECUTAR("DPDOCPROPREGRA",oForm,lSave)

/*
// Consultar Proveedor
*/
FUNCTION CONPROVEEDOR()
  LOCAL lFound:=.F.

  lFound:=!Empty(oDocPro:DOC_CODIGO) .AND. SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))=oDocPro:DOC_CODIGO

  IF lFound  
     EJECUTAR("DPPROVEEDORCON",oDoc,oDocPro:DOC_CODIGO)
  ENDIF

  IF !lFound .AND. oDocPro:nOption<>0
     EVAL(oDocPro:oDOC_CODIGO:bAction) // Lista los Clientes
  ENDIF

RETURN .T.

FUNCTION RUNDESC()
  LOCAL nBruto:=0,nDesc

  nBruto:=oDocPro:aGrids[1]:GetTotal("MOV_TOTAL")

  nDesc :=EJECUTAR("DPDOCDESC",oDoc,nBruto,oDocPro:DOC_DESCCO,!oDocPro:nOption=0)

RETURN .T.


/*
// Totalizar
*/
FUNCTION TOTALIZAR(lEdit)

     IF oDocPro:DOC_NETO=0 
        RETURN .F.
     ENDIF

     EJECUTAR("DOCTOTAL",oDoc , .T. ,NIL , NIL , .F.,oDocPro:nOption>0)

RETURN .T.

FUNCTION VALNUMERO()
   LOCAL lResp:=.F.

   IF EMPTY(oDocPro:DOC_NUMERO)
      MensajeErr("Indique Número del Documento")
      RETURN .F.
   ENDIF

   lResp:=EJECUTAR("DPDOCPROVALNUM",oDoc)

RETURN lResp

// Se ejecuta desde Comprobante de Pago
FUNCTION UPDATEPAGO()

  IF oDocPro:nOption!=1
    oDocPro:DOC_ESTADO:=MYSQLGET("DPDOCPRO","DOC_ESTADO",oDocPro:cWhere)
  ENDIF

  oDocPro:oEstado:Refresh(.T.)  

RETURN .T.

// EOF



