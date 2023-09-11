// Programa   : DPDOCPRO_10IVA
// Fecha/Hora : 22/12/2016 02:18:31
// Prop�sito  : Documento de Compras
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDocPro,lOn)
  LOCAL cTitle :="",nAt,cTitle

  DEFAULT oDocPro:=EJECUTAR("DPDOCPRO","FAC"),;
          lOn    :=.T.

  oDocPro:lLimite     :=lOn      // Documento con Limites
  oDocPro:lPagEle     :=lOn      // Pago en formas electr�nica
  oDocPro:nLimite     := 2000000 // Limite del Monto
  oDocPro:cTipPer     :="N,J"    // Personas Naturales
  oDocPro:nIvaGN      :=12-3     // Iva GN es 9%
  oDocPro:nIvaGN2     :=12-5     // Iva GN es 7%

  oDocPro:cTipIvaLim  :="PE"         // Tipo de IVA
  oDocPro:dDesdeLim   :=oDp:dDesdePE // CTOD("24/12/2016")
  oDocPro:dHastaLim   :=oDp:dHastaPE // CTOD("24/12/2016")+90
  oDocPro:cTitleCli   :="Clientes [Personas Naturales y Jur�dicas]"

  cTitle :=oDocPro:oWnd:cTitle

  nAt   :=AT("|",cTitle)

  IF nAt>0

     cTitle:=LEFT(cTitle,nAt-1)
     oDocPro:oWnd:SetText(cTitle)
     oDocPro:cTitle_:=cTitle

  ENDIF
 
  IF lOn

    IF !("Electr�nico"$oDocPro:oWnd:cTitle)
      oDocPro:oWnd:SetText(oDocPro:oWnd:cTitle+" | Pago Electr�nico |")
    ENDIF

   // oDocPro:lPar_AutoImp:=.F. // No AutoImprime

  ELSE

    oDocPro:cWhereCli   :="(LEFT(CLI_SITUAC,1)='A' OR LEFT(CLI_SITUAC,1)='C' OR LEFT(CLI_SITUAC,1)='P') "
    oDocPro:nLimite     :=0
   // oDocPro:lPar_AutoImp:=oDocPro:lParAutoImp // Restaura AutoImpresi�n
    oDocPro:dDesdeLim   :=CTOD("")
    oDocPro:dHastaLim   :=CTOD("")

  ENDIF

  oDocPro:cTitle_:=oDocPro:oWnd:cTitle

RETURN nil
// EOF

