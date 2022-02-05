(*
** Disassemblatore Z80.
** Progetto Z80 1991/92.
** Scritto da Talent Boy.
** Versione TP3.
*)

(* Converte una word in una stringa esadecimale *)
function wtoh( var num:word ):STR;
Begin
        wtoh:=btoh(num[0])+btoh(num[1]);
End;


(* Ricerca un opcode all'interno della lista IsrVet *)
(* Valori di ritorno:
** =0 non trovato.
** >=1 trovato.
*)
function RicercaIsr ( var opcode:OPCVET (*array degli opcodes *)  ):int;
var
   i,c,f,inizio,fine,meta:integer;
   res:boolean;
Begin
     inizio := 1;
     fine:=MAXISR;
     i:=1;
     res:=FALSE;
     repeat
          meta:=(inizio+fine) div 2;

          while (not res) and (opcode[i] = IsrVet[meta].OpcDat[i]) do
          Begin
                if (IsrVet[meta].OpcNum = i) then
                        res:=TRUE
                else
                Begin
                        if (meta>1) then
                        Begin
                                f:=meta-1;
                                c:=i+1;
                                while (f>0) and (c>i) do
                                begin
                                        c:=1;
                                        while (c<=i) and (IsrVet[f].OpcDat[c]=opcode[c]) do
                                                c:=c+1;
                                        f:=f-1;
                                end;
                                inizio:=f+1;
                        End;

                        if (meta<MAXISR) then
                        Begin
                                f:=meta+1;
                                c:=i+1;
                                while (f<=MAXISR) and (c>i) do
                                begin
                                        c:=1;
                                        while (c<=i) and (IsrVet[f].OpcDat[c]=opcode[c]) do
                                                c:=c+1;
                                        f:=f+1;
                                end;
                                fine:=f-1;
                        End;

                        i:=i+1;
                        meta:=(inizio+fine) div 2;
                End;
          End;

          if (not res) then
          Begin
                  if (opcode[i]< IsrVet[meta].OpcDat[i]) then
                        fine:=meta-1
                  else
                        inizio:=meta+1;
          End;
     until (res) OR (fine<inizio);

     if (res) then
        RicercaIsr:=meta
     else
        RicercaIsr:=0;
End;

(* Disassemblatore:
** Input:  Indirizzo di compilazione.
**         Indice x,y del record dell'istruzione.
**         Operando.
** OutPut: Stringa sorgente
*)

function Disassemblatore( var MemInd:int; x:integer ): BOOL;
var
        bline,line,ex:STR;
        lun,c,i:int;
        w:word;
	din:word;
Begin
(* Crea l'indirizzo di memoria in forma esadecimale *)
        w[1]:=MemInd mod 256;
        w[0]:=MemInd div 256;

(* Memorizza l'indirizzo di memoria *)
        ex:=wtoh(w);
        line:=ex+' ';

(* Memorizza gli opcodes nella MemCpl *)
        for i:=1 to IsrVet[x].OpcNum do
        Begin
             ex:=btoh(IsrVet[x].OpcDat[i]);
             line:=line+ex+' ';
        End;

        MemInd:=MemInd+IsrVet[x].OpcNum;

(* Memorizza gli operandi nella memoria di compilazione *)
        if (IsrVet[x].DinNum>0) then
	Begin
                for c:=MemInd to (MemInd+IsrVet[x].DinNum-1) do
                Begin
			din[2-c+MemInd-1]:=VM.Memory[c];
                        ex:=btoh(VM.Memory[c]);
                        line:=line+ex+' ';
                End;

		MemInd:=MemInd+IsrVet[x].DinNum;
	End;
(* genera l'istruzione completa della parte dinamica *)
        lun:=length(IsrVet[x].OpcStr);
        if ( IsrVet[x].DinPosA>0 ) then
        Begin
             if (IsrVet[x].DinPosB>0) then
             Begin
                  bline := copy( IsrVet[x].OpcStr, 1, IsrVet[x].DinPosB-1 );
                  ex := btoh (din[0]);
                  bline := bline + copy (ex,1,2);
                  bline:=bline+ copy(IsrVet[c].OpcStr, IsrVet[x].DinPosB, lun);
                  lun:=length(bline);
                  line := line + copy ( bline,1,IsrVet[x].DinPosA-1);
                  ex := btoh (din[1]);
                  line := line + copy(ex,1,2);
                  line := line + copy ( bline,IsrVet[x].DinPosA, lun);
             End
             else
             Begin
                 line := line + copy( IsrVet[x].OpcStr, 1, IsrVet[x].DinPosA-1 );
                 if (IsrVet[x].DinNum=2) then
                         ex := wtoh (din)
                 else
                         ex := btoh (din[1]);
                 line := line + ex;
                 line := line+copy( IsrVet[x].OpcStr, IsrVet[x].DinPosA, lun-IsrVet[x].DinPosA+1 );
             End;
        End
        else
                line := line+copy( IsrVet[x].OpcStr, 1, lun );

(* Stampa la linea *)
                Writeln(line);
(* Ok e' andato tutto a posto *)
                Disassemblatore:=true;
End;

function LoopDSM ( IndSorg: int; NumBytes: int ):integer; (*numero di linee compilate*)
var
        buffer:array[1..5] of byte;
        line:STR;
        numlines:int;
        err:BOOL;
        din,w:word;
        opc:OPCVET;
        MemInd:int;
Begin
(* Inizializza l'origine del programma *)
        MemInd:=IndSorg;
(* Inizializza il numero di linee decompilate *)
        numlines:=0;

(* Inizializza flag errore *)
        err:=FALSE;

(* Inizializza il buffer *)
(* Inizia il ciclo principale del programma *)

        repeat

                for i:=1 to 3 do
                        opc[i]:=VM.Memory[MemInd+i-1];

(* Ricerca all'interno del vettore *)
                res:=RicercaIsr( opc );
(* Se l'istruzione non esiste allora genera una riga vuota *)
                if (res=0) then
                Begin
                        if ( (MemInd+12) <= MEMSIZE) then
                        Begin
                                w[1]:=MemInd mod 256;
                                w[0]:=MemInd div 256;
                                line:=copy(wtoh( w ),1,4);
                                line:=line+' '+copy(btoh(VM.Memory[MemInd]),1,2)+' ???';
                                Writeln(line);
				MemInd:=MemInd+1;
                                NumBytes:=NumBytes-1;
                                if (MemInd>MEMSIZE) then
                                        MemInd:=0;

                                numlines:=numlines+1;
                                i:=6;
                        End
                        else
                                err:=TRUE;
                End
                else
                Begin
(* Riempi gli arrays di parte dinamica e opcodes *)
(* Aggiusta il buffer. *)

(* Disassemblaggio *)
                        err:= not Disassemblatore(MemInd,res,din);
(* Shift nel buffer *)

                        numlines:=numlines+1;
			NumBytes:=NumBytes-IsrVet[res].OpcNum-IsrVet[res].DinNum;
                End;

        until (err) OR (NumBytes<=0);

(* Fine del ciclo *)

        if (err) then
                Writeln('Overflow del buffer');

        LoopDSM:=numlines;
End;
