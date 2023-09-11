// Programa   : DPDOCPRORTIREC
// Fecha/Hora : 12/01/2012 00:39:40
// Propósito  :
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   LOCAL oTable,oInsert,oRti,I

   oTable:=OpenTable(" SELECT DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,SUM(DOC_NETO*DOC_CXP),COUNT(*) AS CUANTOS FROM DPDOCPRO "+;
                     " WHERE DOC_TIPDOC"+GetWhere("=","RTI")+" AND DOC_ACT=1  "+;
                     " GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO "+;
                     " HAVING SUM(DOC_NETO*DOC_CXP)>0 "+;
                     " ORDER BY DOC_CODIGO,DOC_NUMERO ",.T.)

   oTable:Browse()

RETURN 


   WHILE !oTable:Eof()

      oRti:=OpenTable("SELECT * FROM DPDOCPRO WHERE DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+;
                                              " AND DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+;
                                              " AND DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+;
                                              " AND DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+;
                                              " AND DOC_TIPTRA='P' AND DOC_ACT=1 ",.T.)
? CLPCOPY(oDp:cSql)

oRti:Browse()

IF .F.


      oInsert:=OpenTable("SELECT * FROM DPDOCPRO ",.F.)
      oInsert:AppendBlank()

      FOR I=1 TO oInsert:Fcount()
         oInsert:FieldPut(I,oRti:Fieldget(I))
      NEXT I

      oInsert:Replace("DOC_TIPTRA","D")
      oInsert:Replace("DOC_CXC"   ,oRti:DOC_CXC*-1)
      oInsert:Commit()

      oInsert:End()
ENDIF

      oRti:End()
             
      oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN NIL
// EOF
