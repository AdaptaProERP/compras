// Programa   : VTAGRIDCODINV
// Fecha/Hora : 07/10/2005 13:53:57
// Propósito  : Valida Código del Producto
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL nExi,nPrecio:=0,oCol,cEquiv:="",cCodInv,aRow:={},cSituac:=""
   LOCAL oInv

   IF oGrid=NIL
      RETURN .F.
   ENDIF

   IF EMPTY(oGrid:MOV_CODIGO)
      RETURN .F.
   ENDIF

   oGrid:cEditar:="N"

   oInv:=OpenTable("SELECT * FROM WHERE INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO),.T.)

   // 02/01/2024 Pasamos todos los campos para no tener necesidad de releerlo.
   AEVAL(oInv:aFields,{|a,n| oGrid:Set(a[1],oInv:FieldGet(n))})
   
   cCodInv:=oInv:INV_CODIGO // SQLGET("DPINV","INV_CODIGO,INV_METCOS,INV_EDITAR,INV_DESCRI,INV_SITUAC","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))
   
   // aRow   :=ACLONE(oDp:aRow)
   cSituac:=oInv:INV_SITUAC // IIF(Empty(oDp:aRow),"",oDp:aRow[5])

? oInv:INV_CODCAR,"INV_CODCAR"
   oInv:End(.T.)

   oGrid:aComponentes:=ASQL("SELECT CPT_COMPON,CPT_UNDMED,CPT_CANTID FROM DPCOMPONENTES WHERE CPT_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))

   IF Empty(cCodInv) 

      // BUSCA EL EQUIVALENTE o CODIGO DE BARRA
      cEquiv:=SQLGET("DPEQUIV","EQUI_CODIG,EQUI_MED","EQUI_BARRA"+GetWhere("=",oGrid:MOV_CODIGO))

      IF Empty(cEquiv)
         RETURN .F.
      ENDIF

      oGrid:Set("MOV_UNDMED",oDp:aRow[2],.T.)
      oGrid:GetCol("MOV_CODIGO"):lListBox:=.F.  
      oGrid:Set("MOV_CODIGO",cEquiv,.T.)
      oGrid:GetCol("MOV_CODIGO"):lTry:=.T. // Repite el Valid  

      RETURN .F.

   ENDIF

   IF EMPTY(oGrid:MOV_NUMMEM) 
      oGrid:NewMemo(SQLGET("DPINV","INV_NUMMEM","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)))
   ELSE
      oGrid:INV_DESCRI:=oInv:INV_DESCRI //  aRow[4] // INV_DESCRI
   ENDIF

   oGrid:cMetodo   :=oInv:INV_METCOS // aRow[2] // INV_METCOS
   oGrid:cEditar   :=oInv:INV_EDITAR //  aRow[3] // INV_EDITAR

   IF oGrid:nOption=1 .OR. oGrid:cEditar<>"S"
      oGrid:cInvDescri:=oInv:INV_DESCRI // aRow[4] // INV_DESCRI
   ENDIF
  

// oGrid:cMetodo:=SQLGET("DPINV","INV_METCOS","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))
   oCol:=oGrid:GetCol("INV_DESCRI")
   oCol:RunCalc()
// oCol:bWhen :=IIF(SQLGET("DPINV","INV_EDITAR","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))="S",".T.",".F.")

   oCol:bWhen :=IIF(oGrid:cEditar="S",".T.",".F.")

   IF cSituac<>"A"
      oGrid:MensajeErr("Código "+cCodInv+" no está Activo")
      RETURN .F.
   ENDIF

   EJECUTAR("VTAGRIDCOSTO" ,oGrid) // Determina el Costo

   EJECUTAR("VTAGRIDSETUNDMED",oGrid) // 08/01/2024


RETURN .T.
// EOF
