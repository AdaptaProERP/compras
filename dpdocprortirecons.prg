// Programa   : DPDOCPRORTIREBUILD
// Fecha/Hora : 01/04/2019 18:21:07
// Propósito  : Rehacer Retenciones de IVA documento de Proveedores. Caso de retenciones de IVA Duplicadas
//              Elimina todos los documentos de retenciones de IVA y los reconstruye desde en enlace entre compras y tablas DPDOCPRORTI
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
   LOCAL cSql,oTable,cCodigo:="",nContar:=0,cNumero:=""
   LOCAL oDoc,cWhere,oDocRti,oNew
   LOCAL oDb:=OpenOdbc(oDp:cDsnData)
   LOCAL lEdit:=.F.,lAnula:=.F.,lPrint:=.F.,lChkRif:=.F.,lMsg:=.F.,lAsk:=.F.,cRun:=NIL,cNumMrt:="",dFchCre
   LOCAL oFrm,cTipDoc

   // Todas las facturas deben generar retencion de ISLR
   cSql:=[ SELECT * FROM DPDOCPRO ]+;
         [ WHERE (DOC_TIPDOC="FAC" OR DOC_TIPDOC="CRE") AND DOC_TIPTRA="D" AND DOC_MTOIVA>0 AND DOC_ACT=1 ]+;
         [ ORDER BY DOC_FCHDEC ]

   oNew:=OpenTable("SELECT * FROM DPDOCPRO",.F.)

   oTable:=OpenTable(cSql,.T.)

   cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
            GetWhereOr("DOC_TIPDOC",{"RTI","RVI"})

   SQLDELETE("DPDOCPRO",cWhere)

   cWhere :="RTI_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)

   SQLDELETE("DPDOCPRORTI",cWhere)

//+" AND "+;
//            "RTI_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)
// oTable:Browse()
// ViewArray(oTable:aDataFill)
   oTable:GoTop()

   oFrm:=MSGRUNVIEW("Reconstruyendo Retenciones de IVA ","Proveedores",oTable:RecCount(),.F.)

   oFrm:FRMSETTOTAL(oTable:RecCount())

   WHILE !oTable:Eof()

      cCodigo:=oTable:DOC_CODIGO
      cContar:=0

      oFrm:FRMSET(oTable:RecNo())

/*
      cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
               "DOC_TIPDOC"+GetWhere("=","RTI"            )+" AND "+;
               "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)

      oFrm:FRMSAY("Calculando Proveedor "+oTable:DOC_CODIGO)

      // Remueve todas las retenciones de IVA del Proveedor
      // oDb:Execute("SET FOREIGN_KEY_CHECKS=0;")

      SQLDELETE("DPDOCPRO",cWhere)

      cWhere :="RTI_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
               "RTI_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)

      SQLDELETE("DPDOCPRORTI",cWhere)
*/

//      WHILE !oTable:Eof() .AND. cCodigo=oTable:DOC_CODIGO

         // Crear Nuevamente las retenciones
         dFchCre:=oTable:DOC_FECHA

         oFrm:FRMSAY("Documento "+oTable:DOC_TIPDOC+"-"+oTable:DOC_CODIGO+"-"+oTable:DOC_NUMERO+" "+LSTR(oTable:RecNo())+"/"+LSTR(oTable:RecNo()))

         EJECUTAR("DPDOCPRORTISAV",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_CODIGO,oTable:DOC_NUMERO,NIL,lEdit,lAnula,lPrint,lChkRif,lMsg,lAsk,cRun,cNumMrt,dFchCre)

         // Si es Pagada, debe clonar la retencion

         IF oTable:DOC_ESTADO="PA"

           cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                    "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                    "DOC_CODIGO"+GetWhere("=",cCodigo          )+" AND "+;
                    "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND "+;
                    "DOC_TIPTRA"+GetWhere("=","P"              )+" AND "+;
                    "DOC_ACT=1"          

           // Si la Factura esta Pagada, debe generar el Documento de Pago

           cSql:=[ SELECT * FROM DPDOCPRO ]+;
                 [ WHERE ]+cWhere

//         ? CLPCOPY(cSql)

           oDoc:=OpenTable(cSql,.T.)
//         oDoc:Browse()
           oDoc:End()


           // Buscar Documento RTI de la factura, segun Documento (DOC_NUMFIS)
           cTipDoc:="RTI"

           IF oTable:DOC_TIPDOC="CRE"
              cTipDoc:="RVI"
           ENDIF

           cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                    "DOC_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
                    "DOC_CODIGO"+GetWhere("=",cCodigo          )+" AND "+;
                    "DOC_NUMFIS"+GetWhere("=",oTable:DOC_NUMFIS)

           cSql:=[ SELECT * FROM DPDOCPRO ]+;
                 [ WHERE ]+cWhere

//          ? CLPCOPY(cSql)

           oDocRti:=OpenTable(cSql,.T.)

           oNew:AppendBlank()
           AEVAL(oDocRti:DbStruct(),{|a,n| oNew:Replace(a[1],oDocRti:FieldGet(n))})
           oNew:Replace("DOC_ESTADO","PA")
           oNew:Replace("DOC_FECHA" ,oDoc:DOC_FECHA)     // Fecha del Pago
           oNew:Replace("DOC_CXP"   ,oDocRti:DOC_CXP*-1) // Cuenta x Pagar
           oNew:Replace("DOC_PAGNUM",oDoc:DOC_PAGNUM)    // Cbte de Pago
//         oDocRti:Browse()
           oDocRti:End()
  
         ENDIF

         oTable:DbSkip()

//    ENDDO

   ENDDO

//   oTable:Browse()
   oTable:End()

   oNew:End()

   oFrm:FRMSAY("Proceso Concluido")

   DpMsgClose()


RETURN NIL
// EOF

