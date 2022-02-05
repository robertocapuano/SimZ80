(* Ordinati in funzione di OpcDat*)
IsrVet[6].OpcStr:='ADDA,';
IsrVet[6].OpcNum:=1;
IsrVet[6].OpcDat[1]:=$C6;
IsrVet[6].DinPosA:=6;
IsrVet[6].DinPosB:=0;
IsrVet[6].DinNum:=1;

IsrVet[5].OpcStr:='ADDA,(HL)';
IsrVet[5].OpcNum:=1;
IsrVet[5].OpcDat[1]:=$86;
IsrVet[5].DinPosA:=0;
IsrVet[5].DinPosB:=0;
IsrVet[5].DinNum:=0;

IsrVet[7].OpcStr:='ADDA,(IX+)';
IsrVet[7].OpcNum:=2;
IsrVet[7].OpcDat[1]:=$DD;
IsrVet[7].OpcDat[2]:=$86;
IsrVet[7].DinPosA:=10;
IsrVet[7].DinNum:=1;

IsrVet[2].OpcStr:='LD(),A';
IsrVet[2].OpcNum:=1;
IsrVet[2].OpcDat[1]:=$32;
IsrVet[2].DinPosA:=4;
IsrVet[2].DinPosB:=0;
IsrVet[2].DinNum:=2;

IsrVet[3].OpcStr:='LDA,()';
IsrVet[3].OpcNum:=1;
IsrVet[3].OpcDat[1]:=$3A;
IsrVet[3].DinPosA:=6;
IsrVet[3].DinPosB:=0;
IsrVet[3].DinNum:=2;

IsrVet[4].OpcStr:='LDA,B';
IsrVet[4].OpcNum:=1;
IsrVet[4].OpcDat[1]:=$78;
IsrVet[4].DinPosA:=0;
IsrVet[4].DinPosB:=0;
IsrVet[4].DinNum:=0;

IsrVet[1].OpcStr:='LDHL,';
IsrVet[1].OpcNum:=1;
IsrVet[1].OpcDat[1]:=$21;
IsrVet[1].DinPosA:=6;
IsrVet[1].DinPosB:=0;
IsrVet[1].DinNum:=2;
