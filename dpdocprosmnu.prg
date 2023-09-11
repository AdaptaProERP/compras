// Programa   : DPDOCPROSMNU
// Fecha/Hora : 10/10/2006 09:48:01
// Propósito  : Menú Finalización Documentos del Proveedor
// Creado Por : JN
// Llamado por: DPDOCPRO
// Aplicación : Compras
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cNumero,cCodigo,cNomDoc,cTipDoc,oForm)
   LOCAL oBtn,oFontB,nAlto:=24-5.0,nAncho:=120,aBtn:={},I,nLin:=0,nHeight,nOption:=0
   LOCAL oDpProSMnu
   DEFAULT cCodSuc:=oDp:cSucursal,;
           cNumero:=STRZERO(1,10),;
           cCodigo:=STRZERO(1,10),;
           cNomDoc:="Solicitud de Cotización",;
           cTipDoc:="FAC"

   AADD(aBtn,{"Expediente" ,"XEXPEDIENTE.BMP","EXP"   })

   IF ValType(oForm)="O"

     nOption:=oForm:nOption
     cNumero:=oForm:cNumero
     cCodigo:=oForm:cCodigo
     cTipDoc:=oForm:cTipDoc

   ENDIF

   IF ValType(oForm)="O" .AND. (oForm:nPar_InvLog<>0 .OR. oForm:nPar_InvFis<>0 .OR. oForm:nPar_InvCon<>0)
      AADD(aBtn,{"Etiquetas","BARCODE.bmp"      ,"ETQ" })
   ENDIF

   IF ValType(oForm)="O" .AND. (oDoc:nPar_InvLog<>0 .OR. oDoc:nPar_InvFis)

     AADD(aBtn,{GetFromVar("{oDp:xDPCENCOS}")  ,"centrodecosto.BMP"       ,"CENCOS" })

   ENDIF

   AADD(aBtn,{"Salir"      ,"XSALIR.BMP"     ,"EXIT"  })

   IF LEN(aBtn)>6
     nAlto:=24-6.3
   ENDIF

   DEFINE FONT oFontB  NAME "MS Sans Serif" SIZE 0, -10 BOLD

   oDpProSMnu:=DPEDIT():New(cNomDoc,"","oDpProSMnu",.F.)

   oDpProSMnu:cCodSuc :=cCodSuc
   oDpProSMnu:cTipDoc :=cTipDoc
   oDpProSMnu:cNumero :=cNumero
   oDpProSMnu:cCodigo :=cCodigo
   oDpProSMnu:oForm   :=oForm
   oDpProSMnu:cNomDoc :=cNomDoc
   oDpProSMnu:lMsgBar :=.F.
   oDpProSMnu:aBtn    :=ACLONE(aBtn)
   oDpProSMnu:nCrlPane:=16772810
   oDpProSMnu:nOption :=nOption
   oDpProSMnu:cNomDoc :=cNomDoc
   oDpProSMnu:cScript :="DPDOCPROSMNU"

   nHeight:=370
   nHeight:=35+((Len(aBtn)+1)*(nAlto*2))
   oDpProSMnu:CreateWindow(nil,70-70,1,nHeight,(nAncho*2)+12)
   oDpProSMnu:oDlg:SetColor(NIL,oDpProSMnu:nCrlPane)

   nLin   :=nAlto

   FOR I=1 TO LEN(aBtn)
 
     @nLin, 01 SBUTTON oBtn OF oDpProSMnu:oDlg;
               SIZE nAncho,nAlto-1.5;	
               FONT oFontB;
               FILE "BITMAPS\"+aBtn[I,2] ;
               PROMPT PADR(aBtn[I,1],20);
               NOBORDER;
               ACTION 1=1;
               PIXEL;
               COLORS CLR_BLUE, {CLR_WHITE, oDpProSMnu:nCrlPane, 1 }

      oBtn:bAction:=BloqueCod("oDpProSMnu:DOCPRORUN(["+aBtn[I,3]+"])")

      nLin:=nLin+nAlto

   NEXT I

   @ .0,1 GROUP oDpProSMnu:oGrupo1 TO nAlto-2.5, nAncho PROMPT "" PIXEL;
          COLOR NIL,oDpProSMnu:nCrlPane

   @ .3,1 SAY "Número:" SIZE 50,09;
          COLOR CLR_BLUE,oDpProSMnu:nCrlPane

   @ .3,6 SAY oDpProSMnu:cNumero SIZE 60,09;
          COLOR CLR_HRED,oDpProSMnu:nCrlPane
  
   oDpProSMnu:Activate({||DOCPROMNUINI()})

RETURN .T.

FUNCTION DOCPROMNUINI()

 oBtn:=oDpProSMnu:oDlg:aControls[1]

 DPFOCUS(oBtn)

RETURN .T.

/*
// Ejecutar
*/
FUNCTION DOCPRORUN(cAction)
  LOCAL oForm:=oDpProSMnu:oForm,lEdit:=.T.

  IF ValType(oForm)="O" .AND. oForm:oWnd:hWnd=0
     oForm:=NIL
     lEdit:=.F.
  ENDIF

  IF cAction="EXIT"

     oDpProSMnu:Close()

     IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
        DpFocus(oDpProMnu:oDlg)
     ENDIF

     RETURN .T.

  ENDIF

/*
  IF cAction="PAGAR"

      RETURN EJECUTAR("DPDOCCLIPAG",oDpProSMnu:cCodSuc,;
                                    oDpProSMnu:cTipDoc,;
                                    oDpProSMnu:cCodCli,;
                                    oDpProSMnu:cNumero,;
                                    oDpProSMnu:cNomDoc)

  ENDIF
*/

  IF cAction="EXP"

     RETURN EJECUTAR("DPDOCPROEXP",NIL,oDpProSMnu:cCodSuc,;
                                       oDpProSMnu:cTipDoc,;
                                       oDpProSMnu:cCodigo,;
                                       oDpProSMnu:cNumero,;
                                       oDpProSMnu:cNomDoc)
  ENDIF

  IF cAction="ETQ"

       EJECUTAR('DPDOCPROETQ',oDpProSMnu:cCodSuc,;
                              oDpProSMnu:cTipDoc,;
                              oDpProSMnu:cCodigo,;
                              oDpProSMnu:cNumero,;
                              oDpProSMnu:cNomDoc , "D"  )

  ENDIF

  IF cAction="CENCOS"

     EJECUTAR("DPMOVINVCENCOS",oDpProSMnu:cCodSuc,;
                               oDpProSMnu:cTipDoc,;
                               oDpProSMnu:cCodigo,;
                               oDpProSMnu:cNumero,.T.)

  ENDIF


RETURN .T.

// EOF


