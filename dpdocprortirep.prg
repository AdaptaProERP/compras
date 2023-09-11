// Programa   : DPDOCPRORTIREP
// Fecha/Hora : 12/06/2005 12:29:55
// Prop¢sito  : Retención de IVA Proveedor
// Creado Por : Juan Navas
// Llamado por: DOCPRORTI
// Aplicaci¢n : Compras
// Tabla      : DPDOCPRORTI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
   LOCAL oRun,oTable,cSql,cWhere:="",cField:="",cWhereRti:=""
   LOCAL cSql,cWhere,I,nAt,aDocPro:={}
   LOCAL cFileDbf  :="",cFileDoc:="",cFilePro:="",cFileRti,cSqlPro:=""
   LOCAL aDpCliZero:={}

   cFileDbf:=oDp:cPathCrp+"DOCPRORTI"    // Datos de la Retención
   cFileDoc:=oDp:cPathCrp+"DOCPRODOC"    // Documento Origen
   cFileRti:=oDp:cPathCrp+"DPDOCPRORTI"  // Documento de Retención
   cFilePro:=oDp:cPathCrp+"DPPROVEEDOR"  // Proveedor

   IF oGenRep=NIL .OR. !oGenRep:oRun:nOut=8
      RETURN .F.
   ENDIF

   /*
   // Genera los Datos del Encabezado
   */

   cSql   :=oGenRep:cSql
   nAt    :=AT(" FROM ",cSql)
   cSql   :="SELECT * "+SUBS(cSql,nAt,LEN(cSql))

   oTable:=OpenTable(cSql,.T.)
   aDocPro:={}
   WHILE !oTable:Eof()
     AADD(aDocPro,{oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_NUMERO,oTable:DOC_CODIGO,oTable:RTI_TIPDOC,oTable:RTI_DOCNUM,oTable:RTI_NUMERO})
     oTable:DbSkip()
   ENDDO
// oTable:End()


   IF ValType(oGenRep)="O" .AND. (oGenRep:oRun:nOut=6 .OR. oGenRep:oRun:nOut=7 .OR. oGenRep:oRun:nOut=8)
      cFileRti:=oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)
      oTable:CTODBF(cFileRti+".DBF")
      oGenRep:oRun:lFileDbf:=.T. // ya Existe
   ELSE
      oTable:CTODBF(cFileRti)
      oTable:End()
   ENDIF

   cSql   :=oGenRep:cSql
   nAt    :=AT(" FROM ",cSql)
   cSql   :="SELECT DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,RTI_DOCTIP,RTI_DOCNUM "+SUBS(cSql,nAt,LEN(cSql))

   FOR I=1 TO LEN(aDocPro)

      cWhere:=cWhere+IIF(Empty(cWhere),""," OR ")+" ("+;
              "DOC_CODSUC"+GetWhere("=",aDocPro[I,1])+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",aDocPro[I,5])+" AND "+;
              "DOC_NUMERO"+GetWhere("=",aDocPro[I,7])+" AND "+;
              "DOC_ACT"+GetWhere("=",1)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",aDocPro[I,4])+")"


      cWhereRti:=cWhereRti+IIF(Empty(cWhereRti),""," OR ")+" ("+;
                 "DOC_CODSUC"+GetWhere("=",aDocPro[I,1])+" AND "+;
                 "DOC_TIPDOC"+GetWhere("=",aDocPro[I,5])+" AND "+;
                 "DOC_NUMERO"+GetWhere("=",aDocPro[I,6])+" AND "+;
                 "DOC_CODIGO"+GetWhere("=",aDocPro[I,4])+")"

   NEXT I

   // Documentos que Originaron la 
   oTable:=OpenTable(" SELECT * FROM DPDOCPRO "+;
                     " LEFT JOIN DPMEMO ON DOC_NUMMEM=MEM_NUMERO "+; 
                     " WHERE DPDOCPRO.DOC_TIPTRA"+GetWhere("=","D")+;
                     IIF( Empty(cWhere),"", " AND "+cWhere),.T.)

   cWhere:=oTable:cWhere


   oTable:REPLACE("ENLETRAS",SPACE(300)) // Enletras

   oTable:REPLACE("DOC_EXONER",0) // Exonerado
   oTable:REPLACE("DOC_BASNET",0) // Base Neta
   oTable:REPLACE("DOC_IMPOTR",0) // Otros Impuestos
   oTable:REPLACE("DOC_MTOIVA",0) // Monto del IVA
   oTable:REPLACE("DOC_BRUTO" ,0) // Monto Bruto


   // IVA B sicas
   oTable:REPLACE("DOC_IMP_EX",0) // Exento
   oTable:REPLACE("DOC_IMP_GN",0) // General
   oTable:REPLACE("DOC_IMP_PE",0) // Electronico
   oTable:REPLACE("DOC_IMP_RD",0) // Reducido
   oTable:REPLACE("DOC_IMP_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_IMP_S2",0) // Suntuario 2
   // Tasas
   oTable:REPLACE("DOC_POR_EX",0) // Exento
   oTable:REPLACE("DOC_POR_GN",0) // General
   oTable:REPLACE("DOC_POR_PE",0) // Electronico
   oTable:REPLACE("DOC_POR_RD",0) // Reducido
   oTable:REPLACE("DOC_POR_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_POR_S2",0) // Suntuario 2
   // Base
   oTable:REPLACE("DOC_BAS_EX",0) // Exento
   oTable:REPLACE("DOC_BAS_GN",0) // General
   oTable:REPLACE("DOC_BAS_PE",0) // Electronico 
   oTable:REPLACE("DOC_BAS_RD",0) // Reducido
   oTable:REPLACE("DOC_BAS_S1",0) // Suntuario 1
   oTable:REPLACE("DOC_BAS_S2",0) // Suntuario 2

   // % De descuentos en Cascada

   oTable:REPLACE("DOC_DESC01",0) // % 1
   oTable:REPLACE("DOC_DESC02",0) // % 2
   oTable:REPLACE("DOC_DESC03",0) // % 3
   oTable:REPLACE("DOC_DESC04",0) // % 4
   oTable:REPLACE("DOC_DESC05",0) // % 5
   oTable:REPLACE("DOC_DESC06",0) // % 6
   oTable:REPLACE("DOC_DESC07",0) // % 7
   oTable:REPLACE("DOC_DESC08",0) // % 8    
   oTable:REPLACE("DOC_DESC09",0) // % 9     
   oTable:REPLACE("DOC_DESC10",0) // % 10

  // Descuento en Monto

   oTable:REPLACE("DOC_DESM01",0) //  1
   oTable:REPLACE("DOC_DESM02",0) //  2
   oTable:REPLACE("DOC_DESM03",0) //  3
   oTable:REPLACE("DOC_DESM04",0) //  4
   oTable:REPLACE("DOC_DESM05",0) //  5
   oTable:REPLACE("DOC_DESM06",0) //  6
   oTable:REPLACE("DOC_DESM07",0) //  7
   oTable:REPLACE("DOC_DESM08",0) //  8    
   oTable:REPLACE("DOC_DESM09",0) //  9     
   oTable:REPLACE("DOC_DESM10",0) //  10

   WHILE !oTable:Eof()

//     EJECUTAR("DPDOCCLIIMP",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_CODIGO,oTable:DOC_NUMERO,;
//                           .F.,oTable:DOC_DCTO,oTable:DOC_RECARG,oTable:DOC_OTROS,"C",oTable:DOC_IVAREB)


      EJECUTAR("DPDOCCLIIMP",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_CODIGO,oTable:DOC_NUMERO,;
                            .F.,oTable:DOC_DCTO,oTable:DOC_RECARG,oTable:DOC_OTROS,"C",oTable:DOC_IVAREB)

     IF oDp:nIVA=0

        EJECUTAR("DPDOCPROIVA",oTable:DOC_CODSUC,oTable:DOC_TIPDOC,oTable:DOC_CODIGO,oTable:DOC_NUMERO,;
                               .F.,oTable:DOC_DCTO,oTable:DOC_RECARG,oTable:DOC_OTROS,NIL,oTable:DOC_IVAREB) // ,"C")
     
     ENDIF

// ViewArray(oDp:aArrayIva)


  // Verifica si la configuracion del sistema manejara las retenciones 
  // con correlativo Infinita(RTI_NUMTRA) o Mensual(RTI_NUMCRR)


    oDp:lRetIva_M:=.T.

    // ? oDp:lRetIva_M ,"oDp:lRetIva_M ",oDp:lRetIvaMul,"oDp:lRetIvaMul"

     // 07/10/2022

     oTable:REPLACE("RTI_NUMCOMP",oDp:lRetIva_M )
     oTable:REPLACE("RTI_RINFME" ,oDp:lRetIva_M )
     oTable:REPLACE("RTI_RETMUL" ,oDp:lRetIvaMul)

     oTable:REPLACE("RTI_RETMUL",.T.) //29/08/2022 oDp:lRetIvaMul)


     oTable:REPLACE("DOC_EXONER",oDp:nMontoEx  )
     oTable:REPLACE("DOC_BASNET",oDp:nBaseNet  )
     oTable:REPLACE("DOC_IMPOTR",oDp:nImpOtr   )   // Otros Impuestos
     oTable:REPLACE("DOC_MTOIVA",oDp:nIva      ) // Otros Impuestos
     oTable:REPLACE("DOC_BRUTO" ,oDp:nBruto    ) // Monto Bruto

     // Base
     oTable:REPLACE("DOC_BAS_EX",oDp:BAS_EX) // Exento
     oTable:REPLACE("DOC_BAS_GN",oDp:BAS_GN) // General
     oTable:REPLACE("DOC_BAS_PE",oDp:BAS_PE) // Electronico
     oTable:REPLACE("DOC_BAS_RD",oDp:BAS_RD) // Reducido
     oTable:REPLACE("DOC_BAS_S1",oDp:BAS_S1) // Suntuario 1
     oTable:REPLACE("DOC_BAS_S2",oDp:BAS_S2) // Suntuario 2
     // Monto de IVA
     oTable:REPLACE("DOC_IVA_EX",oDp:IVA_EX) // Exento
     oTable:REPLACE("DOC_IVA_GN",oDp:IVA_GN) // General
     oTable:REPLACE("DOC_IVA_PE",oDp:IVA_PE) // Electronico
     oTable:REPLACE("DOC_IVA_RD",oDp:IVA_RD) // Reducido
     oTable:REPLACE("DOC_IVA_S1",oDp:IVA_S1) // Suntuario 1
     oTable:REPLACE("DOC_IVA_S2",oDp:IVA_S2) // Suntuario 2

//? oDp:IVA_GN,"oDp:IVA_GN"

// ? oDp:IVA_RD,"RD",oTable:DOC_IVA_RD

     // Monto de IVA
     oTable:REPLACE("DOC_POR_EX",oDp:POR_EX) // Exento
     oTable:REPLACE("DOC_POR_GN",oDp:POR_GN) // General
     oTable:REPLACE("DOC_POR_PE",oDp:POR_PE) // Electronico
     oTable:REPLACE("DOC_POR_RD",oDp:POR_RD) // Reducido
     oTable:REPLACE("DOC_POR_S1",oDp:POR_S1) // Suntuario 1
     oTable:REPLACE("DOC_POR_S2",oDp:POR_S2) // Suntuario 2

     oTable:REPLACE("ENLETRAS",PADR(ENLETRAS(oTable:DOC_NETO),300))
     oTable:DbSkip()

   ENDDO

//oTable:Browse()

   oTable:CTODBF(cFileDoc)
   oTable:End()

   // Datos del Cliente
   oTable :=OpenTable("SELECT * FROM DPPROVEEDORCERO",.F.)
   aDpCliZero:={}

   Aeval(oTable:aFields,{|a,n|AADD(aDpCliZero,a[1])})
   oTable :=OpenTable("SELECT * FROM DPPROVEEDOR",.F.)

   FOR I=1 TO oTable:FCOUNT()

       cField:=STRTRAN(oTable:FieldName(i),"PRO_","CCG_")
       nAt   :=ASCAN(aDpCliZero,{|a,n|ALLTRIM(a)=ALLTRIM(cField)})

       IF nAt>0
          cField:="IF(DOC_CODIGO='0000000000',DPPROVEEDORCERO."+aDpCliZero[nAt]+",DPPROVEEDOR."+oTable:FieldName(I)+") AS "+oTable:FieldName(I)
       ELSE
          cField:="DPPROVEEDOR."+oTable:FieldName(I)
       ENDIF

       cSqlPro:=cSqlPro+IIF(!Empty(cSqlPro),",","")+cField
       
   NEXT I

   oTable:End()

   cSqlPro:=" SELECT DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,"+;
            cSqlPro+;
            " FROM DPPROVEEDOR "+;
            " INNER JOIN DPDOCPRO ON DOC_CODIGO=PRO_CODIGO "+;
            " LEFT  JOIN DPPROVEEDORCERO ON DOC_CODSUC=CCG_CODSUC AND "+;
            "            DOC_TIPDOC=CCG_TIPDOC AND "+;
            "            DOC_CODIGO=CCG_CODIGO AND "+;
            "            DOC_NUMERO=CCG_NUMDOC "+;
            " "+cWhere

   //? CLPCOPY(cSqlPro) 

   oTable:=OpenTable(cSqlPro,.T.)
   oTable:CTODBF(cFilePro)
   oTable:End()

   CLOSE ALL

   // Documentos de Cxp que Originan las Retenciones
   FERASE(cFileDoc+".CDX")
   USE (cFileDoc+".DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON DOC_TIPDOC+DOC_CODIGO+DOC_NUMERO TAG "DPDOCPRODOC" TO (cFileDoc+".CDX")

   CLOSE ALL

   // Retenciones
   FERASE(cFileRti+".CDX")
   USE (cFileRti+".DBF") VIA "DBFCDX" EXCLU NEW
   INDEX ON RTI_TIPDOC+DOC_CODIGO+DOC_NUMERO TAG "DPDOCPRORTI" TO (cFileRti+".CDX")

   CLOSE ALL

   // Proveedor
   FERASE(cFilePro+".CDX")
   USE (cFilePro+".DBF") VIA "DBFCDX" EXCLU NEW

   INDEX ON DOC_TIPDOC+DOC_CODIGO+DOC_NUMERO TAG "DPPROVEEDOR" TO (cFilePro+".CDX")

   CLOSE ALL

RETURN .T.
// EOF
