OpcLst[0,2].OpcStr:='LDA,B';
OpcLst[0,2].OpcNum:=1;
OpcLst[0,2].OpcDat[1]:=$78;

OpcLst[0,1].OpcStr:='ADDA,(HL)';
OpcLst[0,1].OpcNum:=1;
OpcLst[0,1].OpcDat[1]:=$86;

OpcLst[1,1].OpcStr:='ADDA,';
OpcLst[1,1].OpcNum:=1;
OpcLst[1,1].OpcDat[1]:=$c6;

OpcLst[1,2].OpcStr:='ADDA,(IX+)';
OpcLst[1,2].OpcNum:=2;
OpcLst[1,2].OpcDat[1]:=$DD;
OpcLst[1,2].OpcDat[2]:=$86;

OpcLst[2,2].OpcStr:='LDA,()';
OpcLst[2,2].OpcNum:=1;
OpcLst[2,2].OpcDat[1]:=$3a;

OpcLst[2,1].OpcStr:='LD(),A';
OpcLst[2,1].OpcNum:=1;
OpcLst[2,1].OpcDat[1]:=$32;

OpcLst[2,3].OpcStr:='LDHL,';
OpcLst[2,3].OpcNum:=1;
OpcLst[2,3].OpcDat[1]:=$21;

