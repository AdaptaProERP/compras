// Programa   : DPDOCPRORTISAV
// Fecha/Hora : 04/05/2012 02:54:26
// Propósito  : Calcular y Guardar Retencion de IVA
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti,lEdit,lAnula,lPrint,lChkRif,lMsg,lAsk,cRun,cNumMrt)
   LOCAL nPorIva:=0,cRif,lOk:=.F.,cDocOrg,nMtoRet:=0,dFecha,dFchDec,dFchDoc,nMtoIva
   LOCAL cNumRti,cNumAAMM,cWhereRti,cWhereDoc
   LOCAL cNumTra,cNumAM,cAAMM,cNumMes,cNumMesM:="" 
   LOCAL oDocRti,oDpDocPro,cWhere,oTable,nNumFis:=0
   LOCAL nLen,lZero
   LOCAL cNumCbt:=""
   LOCAL dFechaD:=""
   LOCAL nAt
   LOCAL oData,cRtiMax:="",dFchDec,cCodMon, nValCam

   DEFAULT oDp:lAutoSeniat:=.F.

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAC"        ,;
           cCodigo:="J312344202" ,;
           cNumero:=STRZERO(1,10),;
           cTipRti:=IF(cTipDoc="FAC","RTI","RVI"),;
           lEdit  :=ISTABMOD("DPDOCPRORTI")      ,;
           lAnula :=.F.          ,;
           lPrint :=.F.          ,;
           lChkRif:=.T.          ,;
           lMsg   :=.F.          ,;
           lAsk   :=.F.          ,;
           cNumMrt:=""


   // Con el fin de que no borre el valor de RTI_NUNNRT cuando se consulta la retencion Hugo/TJ
   cWhere:="RTI_NUMERO"+GetWhere("=",cNumero) + " AND " +;
           "RTI_CODSUC"+GetWhere("=",cCodSuc) + " AND " +;
           "RTI_TIPDOC"+GetWhere("=",cTipDoc) + " AND " +;
           "RTI_CODIGO"+GetWhere("=",cCodigo)

   oTable:=OpenTable("SELECT RTI_NUMMRT FROM DPDOCPRORTI WHERE "+cWhere,.T.)

   IF !Empty(oTable:RTI_NUMMRT)
      cNumMrt:=SQLGET("DPDOCPRORTI","RTI_NUMMRT",cWhere)
   ENDIF


   IF cTipDoc="RTI" .OR. cTipDoc="RET" .OR. cTipDoc="RVI" 
      MensajeErr("Documento "+cTipDoc+" no aplica Retención")
      RETURN .F.
   ENDIF

   /*
   // Busca la Factura de Compra
   */

   IF Empty(SQLGET("DPDOCPRO","DOC_NUMERO,DOC_FECHA,DOC_MTOIVA,DOC_NUMFIS,DOC_FCHDEC,DOC_CODMON,DOC_VALCAM",;
                                  "DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                  "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                  "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                  "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                  "DOC_TIPTRA"+GetWhere("=","D"    )))

        MensajeErr("Documento "+cTipDoc+" Codigo: "+cCodigo+" Número: "+cNumero+" no Existe")

        RETURN .F.

   ENDIF

   // Tomamos los Datos del Documento

   dFchDoc:=oDp:aRow[2]
   nMtoIva:=oDp:aRow[3]
   nNumFis:=oDp:aRow[4]
   dFchDec:=oDp:aRow[5] // fecha declaracion de la factura. La retencion debe tener su propia fecha declaración
   cCodMon:=oDp:aRow[6] // moneda del Documento
   nValCam:=oDp:aRow[7] // moneda del Documento


   IF Empty(nMtoIva)
      MensajeErr("Documento no posee IVA")
      RETURN .F.
   ENDIF

   cRif:=SQLGET("DPPROVEEDOR","PRO_RIF","PRO_CODIGO"+GetWhere("=",cCodigo))

   IF Empty(cRif)
      MensajeErr(oDp:xDPPROVEEDOR+" "+cCodigo+" no posee Rif "+cRif)
      RETURN .F.
   ENDIF

   cTipRti:="RTI"

   IF EJECUTAR("DPTIPCXP",cTipDoc)=-1 
     cTipRti:="RVI"
   ENDIF

   /*
   // Condición para Buscar la Retencion de IVA 
   */   

   cWhereRti:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "RTI_DOCTIP"+GetWhere("=",cTipRti)+" AND "+;
              "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "RTI_NUMERO"+GetWhere("=",cNumero)

//? cWhereRti,"cWhereRti save"


   IF lAnula

     //
     // Cuando Anula debe buscar la retención.
     //

     /*
     // Debe Buscar en DPDOCPRO para Anular
     */

     cNumRti:=SQLGET("DPDOCPRORTI","RTI_DOCNUM",cWhereRti)

     IF Empty(cNumRti)
        MensajeErr("No existe Documento: "+cTipDoc+" - "+cCodigo+" - "+cNumero+" para Anular")
        RETURN .F.
     ENDIF

     cWhereDoc:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",cTipRti)+" AND "+;
                "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",cNumRti)+" AND "+;
                "DOC_TIPTRA"+GetWhere("=","D"    )

     SQLUPDATE("DPDOCPRO",{"DOC_ESTADO","DOC_ACT"},{"NU",0},cWhereDoc)


     cNumCbt:=SQLGET("DPDOCPRO","DOC_CBTNUM,DOC_FECHA",cWhereDoc)
     dFechaD:=DPSQLROW(2)

     // Remueve Asientos Contables
     IF !Empty(cNumCbt) 
       EJECUTAR("ISCONTAB_ACT",cNumCbt,dFechaD,cTipRti,cNumRti,cCodigo,"D",NIL,"COM",.T.,NIL)
     ENDIF


//   SQLUPDATE("DPDOCPRO","DOC_ACT",0,cWhereDoc)

     // Debe Remover los Asientos Contables

     IF lEdit
       EJECUTAR("DPDOCPRORTIEDIT",cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti)
     ENDIF

     RETURN .T.
   ENDIF

   SysRefresh(.T.)

   CursorWait()

   IF lMsg
      MensajeErr("Será calculada la Retención del IVA ")
   ENDIF

   // Verifica los Datos en el Seniat
   // 14/08/2023 desactivado por ser lento 
   IF (oDp:lAutoSeniat .AND. lChkRif) .AND. .F.

     oDp:lChkIpSeniat:=.F. // No revisar la Web

     MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
            {|| lOk:=EJECUTAR("VALRIFSENIAT",cRif,!ISDIGIT(cRif),ISDIGIT(cRif)) })

     // Es Autodeterminado cuando es Cedula

     IF !lOk

       MsgRun("Verificando RIF "+cRif,"Por Favor, Espere",;
              {||lOk:=EJECUTAR("RIFVAUTODET",cRif,NIL)})
     ENDIF

     IF !Empty(oDp:aRif) .AND. !Empty(oDp:aRif[1])

        SQLUPDATE("DPPROVEEDOR",{"PRO_NOMBRE","PRO_RETIVA"},{oDp:aRif[1],oDp:aRif[2]},"PRO_CODIGO"+GetWhere("=",cCodigo))
  
     ENDIF
   
   ENDIF

   nPorIva:=SQLGET("DPPROVEEDOR","PRO_RETIVA","PRO_CODIGO"+GetWhere("=",cCodigo))

   IF Empty(nPorIva) 

      MensajeErr(oDp:xDPPROVEEDOR+" "+cCodigo+" no posee % Retención de IVA ")

      IF ISTABMON("DPPROVEEDOR")
         EJECUTAR("DPPROVEEDOR",3,cCodigo)
         oProvee:oFolder:SetOption(2)
         nAt:=ASCAN(oProvee:oScroll2:aData,{|a,n|ALLTRIM(UPPE(a[1]))="PRO_RETIVA"})

         IF nAt>0
           oProvee:oScroll2:oBrw:nRowSel:=nAt
//         oProvee:oScroll2:oBrw:KeyBoard(13)
//         oProvee:oScroll2:oBrw:aCols[2]:Edit()
//         oProvee:oScroll2:oBrw:DrawLine(.T.)
         ENDIF

      ENDIF

      RETURN .F.
   ENDIF

   // Realiza el Calculo de Impuestos

   EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodigo,cNumero,.F.,NIL,NIL,NIL,"C",cDocOrg)

   // Factura/Devolucion Excenta no requiere Retención

   IF Empty(oDp:nIva)

      IF !oDp:lRetIva_A .AND. lMsg
        MsMemo("Documento: "+cTipDoc+" - "+cCodigo+" - "+cNumero+" no posee IVA")
      ENDIF

      RETURN .F.

   ENDIF

   nMtoRet:=PORCEN(oDp:nIva,nPorIva) // Calcula Monto de la Retención

   // Las Fecha de la Retencion
   dFecha :=MAX(oDp:dFecha,dFchDoc) // Toma la Fecha Mayor entre el Sistema y Documento (Caso Cambio de Fecha)

   dFchDec :=MAX(oDp:dFecha,dFchDoc) // Fecha de Declaracion para que cuando se modifique No se
                                     // altere el valor de RTI_FCHDEC   
 
//   dFchDec:=dFecha // Fecha de Declaración ANTES
   
   // Almacenar Resultados
   // Cada Proveedor tiene su Correlativo de Retencion RTI_DOCNUM, es incremental 
   // El numero de la Factura es RTI_NUMERO 
   // El consecutivo General todas las retenciones es RTI_NUMTRA (Número de Retenciones Emitido por la empresa para todos los proveedores)
   // Guardar Nuevo Registro DPDOCPRO
   // La relacion entre DPDOCPRORTI con DPDOCPRO es Mediante RTI_DOCNUM, es decir la retencion es Hija de la factura de compra
   // Guardar Nuevo Registro DPDOCPRORTI
   // Busca si esta factura Tiene Retencion
   //   cWhereRti:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
   //              "RTI_DOCTIP"+GetWhere("=",cTipRti)+" AND "+;
   //              "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
   //             "RTI_NUMERO"+GetWhere("=",cNumero)

   oDocRti:=OpenTable("SELECT * FROM DPDOCPRORTI WHERE "+cWhereRti,.T.)

   IF oDocRti:RecCount()=0

 
      oData  :=DATASET("SUC_P"+oDp:cSucursal,"ALL")
      cRtiMax:=oData:Get("RTI"+"Numero",cNumero)
      oData:End(.F.)

// ? cRtiMax,"cRtiMax"

    
      // Antes No notificaba si se queria aplicar la retencion TJ
      /*
      IF (!oDp:lRetIva_A .OR. lAsk) .AND. (lAsk .AND. !MsgYesNo("Sera Aplicado % "+LSTR(nPorIva)+" al Monto de IVA "+FDP(oDp:nIva,"999,999,999,999.99")+ "#"+,oDp:cSelUnaOpc))
        oDocRti:End()
        RETURN .F.
      ENDIF
      */

/*
04/10/2022
      IF (!oDp:lRetIva_A .OR. lAsk) .AND. !MsgYesNo("Sera Aplicado % "+LSTR(nPorIva)+" al Monto de IVA "+LSTR(oDp:nIva),oDp:cSelUnaOpc)
        oDocRti:End()
        RETURN .F.
      ENDIF

      oDocRti:Append()
*/
      cAAMM  :=SUBS(DTOS(dFecha),3,4)

      nLen   :=SQLGET("DPTIPDOCPRO","TDC_LEN" ,"TDC_TIPO"+GetWhere("=",cTipRti)) // "RTI"))
      lZero  :=SQLGET("DPTIPDOCPRO","TDC_ZERO","TDC_TIPO"+GetWhere("=",cTipRti)) // "RTI"))

      IF nLen>0 .AND. lZero
         cRtiMax:=STRZERO(VAL(cRtiMax),nLen)
      ENDIF

      // SQLINCREMENTAL(cTable,cField,cWhere,oDb,cMax,lZero,nLen)
      // Numero de Retencion secuencial del Proveedor 
      // 06/10/2022 no se puede repetir la retencion
      // cNumRti:=SQLINCREMENTAL("DPDOCPRORTI","RTI_DOCNUM","RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
      //                                                   "RTI_CODIGO"+GetWhere("=",cCodigo),NIL,NIL,lZero,nLen)

      cNumRti:=SQLINCREMENTAL("DPDOCPRORTI","RTI_DOCNUM","RTI_CODSUC"+GetWhere("=",cCodSuc),NIL,NIL,lZero,nLen)

      IF nLen>1 .AND. lZero
        cNumRti:=STRZERO(VAL(cNumRti),nLen)
      ENDIF

      cNumTra:=SQLINCREMENTAL("DPDOCPRORTI","RTI_NUMTRA","RTI_CODSUC"+GetWhere("=",cCodSuc))

      cNumTra:=IF(VAL(cRtiMax)>VAL(cNumTra),cRtiMax,cNumTra)
      cNumRti:=cNumTra // 07/10/2022 
      // cNumRti:=IF(VAL(cRtiMax)>VAL(cNumRti),cRtiMax,cNumRti)

      IF (!oDp:lRetIva_A .OR. lAsk) .AND. !MsgYesNo("Sera Aplicado % "+LSTR(nPorIva)+" al Monto de IVA "+ALLTRIM(FDP(oDp:nIva,"999,999,999,999.99"))+" #"+cNumTra+CRLF+;
          "Origen:"+cTipDoc+"-"+cCodigo+"-"+cNumero,oDp:cSelUnaOpc)
        oDocRti:End()
        RETURN .F.
      ENDIF

// ? cNumTra,cRtiMax

      //
      // Correlativo del mes, sin tomar en cuenta el proveedor
      //

/* De esta manera coloca el mismo numero en RTI_NUMRET
      cNumMes:=SQLINCREMENTAL("DPDOCPRORTI","RTI_NUMRET","RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                         "RTI_NUMRET"+GetWhere("<>",cNumMrt)+" AND "+;
                                                         "RTI_AAMM  "+GetWhere("=",cAAMM  ))
*/

      cNumMes:=SQLINCREMENTAL("DPDOCPRORTI","RTI_NUMRET","RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                         "RTI_AAMM  "+GetWhere("=",cAAMM  ))

     // Para que siga el correlativo en caso que se aplique una retencion de Iva individual TJ

     IF LEN(cNumMrt)=0 
        cNumMrt:=SQLINCREMENTAL("DPDOCPRORTI","RTI_NUMMRT","RTI_CODSUC"+GetWhere("=",oDp:cSucursal),NIL,NIL,lZero,nLen)
     ENDIF

     IF LEN(ALLTRIM(cNumMes))<>LEN(cNumMes)
        cNumMes:=STRZERO(VAL(cNumMes),LEN(cNumMes))
     ENDIF

     cNumMes:=LEFT(cNumMes,8)

     // cNumMes:=cAAMM+RIGHT(cNumMes,4)

     cWhereRti:=NIL

     // 21/12/2022
     dFchDec:=EJECUTAR("GETVALFCHDEC",dFecha)

   ELSE

      // Modificar
      cNumRti:=oDocRti:RTI_DOCNUM
      cNumTra:=oDocRti:RTI_NUMTRA
      cNumMes:=oDocRti:RTI_NUMRET
      dFecha :=oDocRti:RTI_FECHA
      dFchDec:=oDocRti:RTI_FCHDEC
      cAAMM  :=SUBS(DTOS(dFecha),3,4)

   ENDIF

   oDocRti:Replace("RTI_CODSUC",cCodSuc)
   oDocRti:Replace("RTI_TIPDOC",cTipDoc)
   oDocRti:Replace("RTI_DOCTIP",cTipRti)
   oDocRti:Replace("RTI_CODIGO",cCodigo)
   oDocRti:Replace("RTI_NUMERO",cNumero)
   oDocRti:Replace("RTI_FCHDEC",dFchDec)
   oDocRti:Replace("RTI_FECHA ",dFecha )
   oDocRti:Replace("RTI_PORIVA",nPorIva)
   oDocRti:Replace("RTI_PORCEN",nPorIva)
   oDocRti:Replace("RTI_TIPTRA","D"    )
   oDocRti:Replace("RTI_AAMM"  ,cAAMM  )
  

   // Numeracion de la Retencion
   oDocRti:Replace("RTI_DOCNUM",cNumRti) // Numero del Documento DPDOCPRO 
   oDocRti:Replace("RTI_NUMTRA",cNumTra) // Correlativo General
   oDocRti:Replace("RTI_NUMRET",cNumMes) // Correlativo del AAMM


   //cNumMesM,cNumMrt

//? cNumMesM,cNumMrt,"cNumMesM,cNumMrt en DPDOCPRORTISAV"

    DEFAULT oDp:aRti:={}

    AADD(oDp:aRti,{cTipRti,cNumRti})

//   IF LEN(cNumMesM)=0

//? "hola"
      cNumMesM:=cNumMes
//   ENDIF

/*
   IF LEN(cNumMrt)=0
      cNumMrt:=cNumTra
   ENDIF
*/

   // Para ser utilizado en Multetenciones
   oDocRti:Replace("RTI_NUMCRR",cNumMesM)
   oDocRti:Replace("RTI_NUMMRT",cNumMrt)
      

   /*
   // Registro del Documento CxP en DPDOCPRO
   // Primero debe Registrar en DPDOCPRO
   */

   cWhereDoc:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cTipRti)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumRti)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D"    )

   oDpDocPro:=OpenTable("SELECT * FROM DPDOCPRO WHERE "+cWhereDoc,.T.)

   IF oDpDocPro:RecCount()=0
      cWhereDoc:=NIL
      oDpDocPro:AppendBlank()
   ENDIF


//? cNumero,"cNumero facturaafectada"

   oDpDocPro:Replace("DOC_CODSUC",cCodSuc)
   oDpDocPro:Replace("DOC_TIPDOC",cTipRti)
   oDpDocPro:Replace("DOC_CODIGO",cCodigo)
   oDpDocPro:Replace("DOC_NUMERO",cNumRti)
   oDpDocPro:Replace("DOC_TIPTRA","D"    )
   oDpDocPro:Replace("DOC_FECHA ",dFecha )
   oDpDocPro:Replace("DOC_FCHDEC",dFchDec)
   oDpDocPro:Replace("DOC_NUMFIS",nNumFis)
   oDpDocPro:Replace("DOC_DCTO"  ,0)
   oDpDocPro:Replace("DOC_RECARG",0)
   oDpDocPro:Replace("DOC_OTROS" ,0)
   oDpDocPro:Replace("DOC_CENCOS",oDp:cCenCos)
   oDpDocPro:Replace("DOC_HORA"  ,TIME())
   oDpDocPro:Replace("DOC_USUARI",oDp:cUsuario)
   oDpDocPro:Replace("DOC_FACAFE",cNumero)  //factura Afectada 

   oDpDocPro:Replace("DOC_NETO"  ,nMtoRet)
   oDpDocPro:Replace("DOC_CXP"   ,EJECUTAR("DPTIPCXP",cTipRti)) 
   oDpDocPro:Replace("DOC_DOCORG","RTI"  )
   oDpDocPro:Replace("DOC_MTOIVA",nMtoRet)
   oDpDocPro:Replace("DOC_BASNET",0      )
   oDpDocPro:Replace("DOC_ACT"   ,1      )
   oDpDocPro:Replace("DOC_ORIGEN","N"    )
   oDpDocPro:Replace("DOC_ESTADO","AC"   )
   oDpDocPro:Replace("DOC_CODMON",cCodMon)
   oDpDocPro:Replace("DOC_VALCAM",nValCam) // nValor del Documento de Origen
   oDpDocPro:Commit(cWhereDoc)

   oDpDocPro:End()

   // DPDOCPRORTI, se graba luego del DPDOCPRO
   oDocRti:Commit(cWhereRti)

   oDocRti:End()
   
   // 07/06/2022
   IF oDp:lRTIFCHVEN

      SQLUPDATE("DPDOCPRO","DOC_FCHDEC",dFchDec,"DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                                "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                                "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                                "DOC_TIPTRA"+GetWhere("=","D"    ))

//      ? oDp:cSql,"ASIGNAR LA FECHA DE DECLARACION"
   ENDIF

   IF !Empty(oDpDocPro:DOC_CBTNUM)

     MsgRun("Contabilizando Retención de IVA" + oDpDocPro:DOC_NUMERO,"Por favor Espere",{||;
            EJECUTAR("DPDOCCONTAB", oDpDocPro:DOC_CBTNUM,;
                             cCodSuc,;
                             cTipRti,;
                             cCodigo,;
                             cNumRti,.F.,.F.) })

   ENDIF

   IF lPrint
     RTIPRINTER()
   ENDIF

   IF !Empty(cRun)
      MACROEJE(cRun)
   ENDIF

   IF lEdit
     EJECUTAR("DPDOCPRORTIEDIT",cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti)
   ENDIF

RETURN .T.

FUNCTION RTIPRINTER()

   EJECUTAR("DPDOCPRORTIPRN",cCodSuc,cTipDoc,cCodigo,cNumero)

/*

   LOCAL oRep
   LOCAL cWhere:="RTI_CODSUC"+GetWhere("=",cCodSuc)

   oRep:=REPORTE("DOCPRORTI",cWhere)

   oRep:SetRango(1,cNumero,cNumero) // Número de la Factura
   oRep:SetRango(2,cCodigo,cCodigo)
   oRep:SetCriterio(1,cTipDoc)      // Puede ser un Reverso de IVA
*/
RETURN .T.

// EOF
