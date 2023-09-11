// Programa   : DPDOCPRORTIFIX
// Fecha/Hora : 01/04/2019 07:29:26
// Propósito  : Reparar Numero de Retenciones de IVA
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oTable,cSql,cNumero,nLen,cWhere,cCodigo,nReg,nNeto

RETURN NIL


  nLen:=SQLGET("DPTIPDOCPRO","TDC_LEN","TDC_TIPO"+GetWhere("=","RTI"))

  cSql:=[ SELECT DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,DOC_TIPTRA,DOC_FECHA,DOC_HORA,DOC_NETO ]+;
          [ FROM DPDOCPRO ]+;
          [ WHERE DOC_TIPDOC="RTI"  AND LENGTH(DOC_NUMERO)=1 ]
          [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

   oTable:=OpenTable(cSql,.T.)

   WHILE !oTable:Eof()

     cNumero:=ALLTRIM(oTable:DOC_NUMERO)
     cNumero:=REPLI("0",nLen-LEN(cNumero))+cNumero

     cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)

     SQLUPDATE("DPDOCPRO","DOC_NUMERO",cNumero,cWhere)

     oTable:DbSkip()

   ENDDO

   oTable:End()

   cSql:=[ SELECT DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,DOC_TIPTRA,DOC_FECHA,DOC_HORA,DOC_NETO ]+;
         [ FROM DPDOCPRO ]+;
         [ WHERE DOC_TIPDOC="RTI" AND LENGTH(DOC_NUMERO)>1 AND LENGTH(DOC_NUMERO)<3 AND DOC_TIPTRA="D" ]
         [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

   oTable:=OpenTable(cSql,.T.)

   WHILE !oTable:Eof()

     cCodigo:=oTable:DOC_CODIGO
     nReg   :=0

     WHILE !oTable:Eof() .AND. cCodigo=oTable:DOC_CODIGO

       cNumero:=ALLTRIM(oTable:DOC_NUMERO)

       cWhere :="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND "+;
                "DOC_NETO"  +GetWhere("=",oTable:DOC_NETO  )
       nReg++

       IF nReg>1

         cNumero:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                                                         "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                                                         "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO))
         cNumero:=ALLTRIM(cNumero)

       ENDIF

       cNumero:=REPLI("0",nLen-LEN(cNumero))+cNumero

// ? oTable:DOC_CODIGO,oTable:DOC_NUMERO,cNumero,"<-NUEVO"

       SQLUPDATE("DPDOCPRO","DOC_NUMERO",cNumero,cWhere)

       oTable:DbSkip()

     ENDDO

   ENDDO

// oTable:Browse()

   oTable:End()

RETURN NIL

   // Busca Pago que no corresponde por montos, caso de factura 10, ahora es 00000010, su pago es 10, debido a que su monto no corresponde.

   cSql:=[ SELECT DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,DOC_TIPTRA,DOC_FECHA,DOC_HORA,DOC_NETO,DOC_PAGNUM,DOC_NUMFIS  ]+;
         [ FROM DPDOCPRO ]+;
         [ WHERE DOC_TIPDOC="RTI" AND LENGTH(DOC_NUMERO)>1 AND LENGTH(DOC_NUMERO)<3 AND DOC_TIPTRA="P"  AND DOC_ACT=1 ]
         [ ORDER BY DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO ]

//  CLPCOPY(cSql)

   oTable:=OpenTable(cSql,.T.)

   WHILE !oTable:Eof()

      cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=","RTI"            )+" AND "+;
              "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D"              )+" AND "+;
              "DOC_NUMFIS"+GetWhere("=",oTable:DOC_NUMFIS)

      cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO",cWhere)

      IF !Empty(cNumero)
         ? cNumero,CLPCOPY(oDp:cSql)
      ENDIF

      oTable:DbSkip()

   ENDDO

   oTable:Browse()
   oTable:End()

RETURN .T.
// EOF
