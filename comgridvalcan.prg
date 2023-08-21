// Programa   : COMGRIDVALCAN
// Fecha/Hora : 09/10/2005 12:17:45
// Propósito  : Valida Cantidad o Existencia
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
  LOCAL nExi:=0,dFecha,cHora,aData:={},i,oCol,nPrecio:=0
  LOCAL lRet:=.T.,oDoc // Valor Retorno

  IF oGrid=NIL
     RETURN .F.
  ENDIF

  oDoc:=oGrid:oHead

  IF  oGrid:lComent .OR. !oDoc:lMoneta
    RETURN .T.
  ENDIF

  IF !oGrid:MOV_CANTID>0
    RETURN .F.
  ENDIF

  dFecha:= oDoc:DOC_FECHA
  cHora := NIL // oDoc:DOC_HORA

  IF oGrid:nOption=3
     dFecha:=oGrid:MOV_FECHA
     cHora :=oGrid:MOV_HORA
  ENDIF

  // JN 24/07/2017, Productos pesados

  DEFAULT oGrid:lPesado:=.F.,;
          oGrid:nCxUnd :=0,;
          oGrid:aComponentes:={}

  IF !Empty(oGrid:aComponentes) 

     IF !EJECUTAR("COMPGETEXI",oGrid,dFecha,cHora,NIL)

        aData:={}

        FOR I=1 TO LEN(oGrid:aComponentes)

           AADD(aData,{oGrid:aComponentes[I,1],;
                       MYSQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:aComponentes[I,1])),;
                       oGrid:aComponentes[I,2],;
                       oGrid:aComponentes[I,3],;
                       oGrid:aComponentes[I,5],;
                       oGrid:aComponentes[I,6],;
                       oGrid:aComponentes[I,7]})

        NEXT I
    
        EJECUTAR("DPCOMPVIEW",aData,oGrid:MOV_CODIGO,"Existencia de Componentes no Cubre Existencia Requerida")

        IF oDoc:nPar_InvAct<0 .AND. !oDoc:lPar_Existe .AND. oGrid:MOV_CANTID>oGrid:nExiste
           RETURN .F.
        ENDIF

      ENDIF

//      EJECUTAR("VTAGRIDPRECIO",oGrid,.T.) // Cambia los precios

      RETURN .F.

  ENDIF

RETURN lRet
// EOF

