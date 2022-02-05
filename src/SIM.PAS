Program SimulatoreZ80(input,output);

const

(* Generici *)

(* Numero caratteri per le stringhe istruzioni *)
        ISMAX = 16;
(* Dimensione Stringa generica *)
        MAXSTR = 80;

(* Assemblatore *)

(*Numero massimo di opcode per riga della matrice*)
        MAXOPC = 128;
(*Numero degli opcode della prima riga *)
        MAXOPC0 = 2;
(*Numero degli opcode della seconda riga *)
        MAXOPC1= 2;
(*Numero degli opcode della terza riga *)
        MAXOPC2= 3;

(*Caratteri ammessi dall'assemblatore *)
        ALFABETOZ80 = 'ABCDEFHIJLMNOPRSTXYZ01234567890+, ()''';

(* Disassemblatore *)

(* Dimensione massima di ogni riga della matrice *)
        MAXISR = 7;

(* Memoria Virtuale Implementata *)
   MEMSIZE = 32767;

(* Simulatore *)

(* Costanti per la gestione dei parametri *)

(* Registri ad 8 bit reali *)
        A = 0;
        F = 1;
        B = 2;
        C = 3;
        D = 4;
        E = 5;
        H = 6;
        L = 7;
        I = 8;
        R = 9;

(* Registri ombra ad 8 bit reali *)

        A1 = 10;
        F1 = 11;
        B1 = 12;
        C1 = 13;
        D1 = 14;
        E1 = 15;
        H1 = 16;
        L1 = 17;

(* Registri a 16 bits virtuali *)

        BC  = 20;
        DE  = 21;
        HL  = 22;
(* Locazione di memoria puntata da (HL) *)
        _HL = 23;
        _BC = 24;
        _DE = 25;
        AF  = 26;
        AF1 = 27;

(* Registri a 16 bits reali *)
        IX = 30;
        IY = 31;
        SP = 32;
        PC = 33;

(* Operandi *)

(* Intero a 8 bits *)
        n   = 40;
(* Intero a 16 bits *)
        nn  = 41;
(* Indirizzo di memoria a 16 bits *)
        _nn = 42;

(* Condizioni di salto *)

        JNZ = 50; (* Z = 0, non zero *)
        JSZ = 51; (* Z = 1, zero     *)
        JNC = 52; (* C = 0, no riporto *)
        JSC = 53; (* C = 1, si riporto *)
        JPO = 54; (* P = 0, parita' dispari *)
        JPE = 55; (* P = 1, parita' pari *)
        JSP = 56; (* S = 0, segno piu' *)
        JSM = 57; (* S = 1, segno meno *)

(* Flags dello Z80 *)
(*

        C   (* Riporto *)
        N   (* Sottrazione, N=0 dopo una sottrazione, N=1 dopo un'addizione *)
        P/V (* Parity/Overflow, P=0 parita' dispari, P=1 parita' pari *)
        H   (* Mezzo riporto *)
        Z   (* Zero *)
        S   (* Segno *)
*)

(*
** Bits usati nel Registro F
** S Z ? H ? PV N C
** 0 1 2 3 4 5  6 7
*)

type

(* Tipi base *)

(* File binario *)
        bin = file of byte;
(* Stringa generica *)
        STR = string[MAXSTR];
(* Stringa istruzioni *)
        ISRSTR = string[ISMAX];

        int = integer;

        WORD = array[0..1] of BYTE;
        BOOL = boolean;

(* Solo per TP3.0 *)
        pointer = ^byte;

(* Assemblatore *)

{ Record contenente i dati per ogni istruzione }
        OpcRec = Record
               OpcStr : ISRSTR;
               OpcNum : 1..3;
               OpcDat : Array[1..3] of BYTE;
        End;

{ Tipo base riga della matrice }
        OPCRIGA = Array[1..MAXOPC] of OpcRec;

(* Disasseblatore *)

(* Record contenente i dati di ogni istruzione per il Dsm *)

        IsrRec = Record
                OpcStr : ISRSTR;  (* Stringa statica *)
                OpcNum : 1..3; (* Numero degli opcodes *)
                OpcDat : array[1..3] of byte; (* Opcodes dell'istruzione *)
                DinPosA: 0..MAXSTR; (* Posizione della stringa dinamica (=0 se assente) *)
                DinPosB: 0..MAXSTR; (* Posizione della stringa dinamica (=0 se assente) *)
                DinNum : 0..2; (* Numero di bytes per la parte dinamica *)
                (* Questi parametri sono significativi solo per il SIM *)
                Punt : pointer; (* Puntatore alla funzione di simulazione *)
                ArgA: byte; (* Tipo del primo argomento dell'istruzione *)
                ArgB: byte; (* Tipo del secondo argomento dell'istruzione *)
        End;

(* Vettore contenenti gli opcodes per la ricerca *)
      OPCVET = array[1..3] of byte;

(* Simulatore *)

(* Record per la simulazione della CPU Z80 *)

        Z80 = Record
                (* Registri A, F, B, C, D, E, H, L, I, R *)
                RegsB : array[0..9] of byte;
                (* Registri A', F', B', C', D', E', H', L' *)
                RegsB1: array[0..7] of byte;
                (* Registri IX, IY, SP, PC *)
                RegsW:  array[0..3] of word;
        End;

(* Macchina Virtuale *)
        VirtualMachine = Record
                  CPU : Z80;
                  Memory: array[0..MEMSIZE] of byte;
        End;

(* Variabili *)
var

(*Matrice degli operandi *)
   OpcLst: Array[0..2] of OPCRIGA;
(*Lunghezza di ogni riga*)
   OpcLun: Array[0..2] of int;
(* Macchina Virtuale *)
   VM: VirtualMachine;

(*
** Matrice contenente le istruzioni dello Z80
** Ogni riga contiene istruzioni con lo stesso numero di opcodes.
** Su questa matrice si dovra' effettuare la ricerca.
*)
        IsrVet : array[1..MAXISR] of IsrRec;

(*$iASM.PAS*)
(*$iDSM.PAS*)

var
        namesorg,namedest:STR;
        ASMSorg:text;
        IndSorg,DSMnum:int;
        s,i,numlines:int;

Begin

{$iVETTORE.H}
(*$iMATRICE.H*)

        OpcLun[0]:=MAXOPC0;
        OpcLun[1]:=MAXOPC1;
        OpcLun[2]:=MAXOPC2;

        Repeat
              repeat
                    WriteLN('1...ASSEMBLATORE');
                    Writeln('2...DISASSEMBLATORE');
                    Writeln('3...SIMULATORE');
                    Writeln('4...FINE');
                    Write('SCELTA (1-4): ');
                    Readln(s);
              UNTIL (s>0) AND (s<5);
              CASE S DO
              1:
              BEgin
                Write('Nome del file sorgente: ');
                Readln(namesorg);
                ASSIGN(ASMsorg,namesorg);
                reset(ASMSorg);
                numlines := LoopASM( ASMsorg );
                WriteLN('Linee Assemblate: ',numlines);
                close(ASMSorg);
              End;
              2:
              BEgin
                Write('Indirizzo Sorgente: ');
                Readln(StrSorg);
                Write('Numero di bytes da DSM: ');
                Readln(DSMnum);
                ATOW(StrSorg,IndSorg);
                numlines := LoopDSM (IndSorg,DSMnum);
                WriteLN('Linee Disassemblate: ',numlines);
              End;
              3:
              ENd;
        until s=4;
End.
