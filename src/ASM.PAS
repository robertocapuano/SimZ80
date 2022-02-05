(* ASSEMBLATORE*)

procedure atow (strsor:str;var ew:word);
var
valore:real;
errore:integer;
w:array[0..1] of real;
begin
  w[0]:=0;
  w[1]:=0;
  val(strsor,valore,errore);
  w[0]:=valore/256;
  w[1]:=valore-int(w[0])*256;
  ew[1]:=trunc(w[1]);
  ew[0]:=trunc(w[0]);
end;

procedure scindestr (strsor:str; var strver:isrstr; var din:word);
var i,j,k,lung,indice:integer;
    parola:array [0..1] of word;
    strnum:isrstr;
begin
  for i:=0 to 1 do
   begin
     parola[0][i]:=0;
     parola[1][i]:=0;
   end;
  strver:='0';
  strnum:='0';
  indice:=0;
  i:=1;
  j:=0;
  k:=0;
  lung:=length(strsor);
  repeat
      if (strsor[i] >= '0') and (strsor[i] <='9') then
        begin
          repeat
            j:=j+1;
            strnum:=strnum+strsor[i];
            i:=i+1;
          until (strsor[i] < '0') or (strsor[i] > '9') or (i=length(strsor) +1);
          atow(strnum,parola[indice]);
          indice:=indice+1;
          strnum:='0';
        end
      else
        begin
          k:=k+1;
          strver:=strver+strsor[i];
          i:=i+1;
        end;
  until i=length(strsor)+1;

  if (indice=1) then
    begin
      din[0]:=parola[0][0];
      din[1]:=parola[0][1];
    end
  else
    begin
      din[0]:=parola[1][1];
      din[1]:=parola[0][1];
    end;
  strver:=copy(strver,2,k);
end;

  procedure aggiusta(var strsor:str);
  var
  ascii,i:integer;
  begin
    for i:=1 to length(strsor) do
      begin
        if (strsor[i] >= 'a') and (strsor[i] <= 'z') then
          begin
            ascii:=ord(strsor[i]);
            ascii:=ascii-97;
            strsor[i]:=chr(65+ascii);
          end;
      end;
end;

function strcpt (strsor:str):ISRSTR;
var st:STR;
 i,lung:integer;
Begin
    if (length(strsor)>0) then
    begin
      lung:=0;
      i:=1;
      while ( (i<=length(strsor)) and (strsor[i]<>';') ) do
        begin
          if (strsor[i]> chr(32)) and (strsor[i] < chr(127)) then
            begin
              lung:=lung+1;            (*conta i caratteri validi*)
              strsor[lung]:=strsor[i]; (*modifica la stringa sorgente*)
            end;
          i:=i+1;
        end;
      st:=copy(strsor,1,lung);     (*crea la stringa compattata*)
      aggiusta(st);
  strcpt:=st;
  end;
End;

function btoh( dec:BYTE ):STR;
const
     HEXDIGITS = '0123456789ABCDEF';
var
     HD : STR;
     stringa : string[2];
Begin
     HD := HEXDIGITS;
     stringa[2]:=HD[(dec mod 16) +1];
     stringa[1]:=HD[(dec div 16) +1];
     stringa[0]:=CHR(2);
     btoh:=stringa;
End;

function Controllo_Sintassi( line: ISRSTR ):BOOL;
var
   c,len,i,lun,pos:integer;
   err,pa,pc,piu,virgola,apice:BOOL;
   alfa:STRING[255];

Begin
     alfa:=ALFABETOZ80;
     len:=length(alfa);
     lun:=length(line);
     i:=1;

(*inizializzazione dei flags*)
     err:=FALSE;
     pa:=FALSE;
     pc:=FALSE;
     piu:=FALSE;
     virgola:=FALSE;
     apice:=FALSE;

     while (i<=lun) AND (NOT err) do
     Begin
          c:=1;
          while (c<=len) AND (alfa[c]<>line[i]) do
                c:=c+1;
          if (c>len) then
             err:=TRUE
          else
          Begin
               if ( line[i]='(' ) then
               Begin
                  err := (pa) OR (pc);
                  pa:=TRUE;
               ENd
               else
               if ( line[i]=')') then
               Begin
                  err:= (NOT pa) or (pc) or (line[i-1]='(');
                  pc:=TRUE;
               End
               else
               if ( line[i]='+') then
               Begin
                    err := (piu) or (i=1) or not ( (line[i-1]>='A') and (line[i-1]<='Z') );
                    err := err OR not ( (line[i+1]>='0') and (line[i+1]<='9') );
                    piu:=TRUE;
               ENd
               else
               if ( line[i]=',') then
               Begin
                    err := (virgola) or (apice) or (line[i-1]='(') or (line[i+1]=')');
                    virgola:=TRUE;
               End
               else
               if ( line[i]='''') then
               Begin
                    err:= (apice) or ( (line[i-1]>='0') and (line[i-1]<='9') );
                    apice:=TRUE;
               End
               else
               if ( (line[i]>='0') and (line[i]<='9') ) then
                   err := ( (line[i-1]>='A') AND (line[i-i]<='Z') );
          End;
          i:=i+1;
     End;

     if ( not err) then
     Begin
          err := ((pa and not pc) OR (not pa and pc));
     End;

     Controllo_Sintassi:= not err;
End;

{ Ricerca all'interna della matrice }
function RicercaOpc ( var OpcArr:OPCRIGA; Lun : int; StrPat:ISRSTR  ):int;
var
   inizio,fine,meta:integer;
   res : boolean;
Begin
     inizio := 1;
     fine:=Lun;
     repeat
          meta:=(inizio+fine) div 2;
          if ( StrPat < OpcArr[meta].OpcStr ) then
             fine:=meta-1
          else
             inizio:=meta+1;
          res :=  (StrPat = OpcArr[meta].OpcStr);
     until ( res ) OR (fine<inizio);

     if ( res ) then
        RicercaOpc:=meta
     else
        RicercaOpc:=0;
End;

{ Ecco il cuore dell'ASM }
function Assemblaggio( var MemInd:int; x,y:integer; Din:word ):BOOL;
var
   i:int;
Begin
     { Se lo spazio di assemblaggio e' finito il programma termina }
     if ( (OpcLst[y,x].OpcNum+y+MemInd) > MEMSIZE ) then
        Assemblaggio:=FALSE
     else
     Begin
          { Copia gli opcodes nella memoria di assemblaggio ( VM.Memory[]) }
          for i:=MemInd to (MemInd+OpcLst[y,x].OpcNum-1) do
                   VM.Memory[i]:=OpcLst[y,x].OpcDat[i-MemInd+1];
          { Aggiorna l'indice della memoria di assemblaggio }
          MemInd:=i+1;
          { Se ci sono operandi nell'istruzione copia anche essi }
          if (y<>0) then
          begin
               { Copia il primo operando }
               VM.Memory[MemInd]:=din[1];
               { Copia anche l'eventuale secondo operando }
               if (y=2) then
                  VM.Memory[MemInd+1]:=din[0];
          { Aggiorna l'indice della memoria di assemblaggio }
               MemInd:=MemInd+y;
          End;
          { Riuscito l'assemblaggio della riga }
          Assemblaggio:=TRUE;
     End;
End;

{ Loop principale del programma }
function LoopASM ( var fp:text ):int;
var
   hex: STR;
   strsta,strcom:ISRSTR;
   buffer:STR;
   line,ind,i,c:int;
   resasm:boolean;
   din,w:word;
   MemInd:int;
Begin
{ Linee assemblate = 0 }
     line:=0;
{ Risultato assemblaggio = riuscito }
     resasm:=TRUE;
{ Indice della riga all'interno della matrice }
     ind:=1;
{ Resetta l'indice di Compilazione *)
     MemInd:=0;
{ Continua finche' non termina il file sorgente, l'assemblaggio non trova errori, esiste l'istruzione nella matrice }
     while ( (not EOF(fp)) and (resasm) and (ind<>0) ) do
     Begin
{ Legge una riga del sorgente }
          repeat
               i:=0;
               repeat
                   i:=i+1;
                   read(fp,buffer[i]);
               until EOLN(fp);
               readln(fp);
               buffer[0]:=chr(i);
               strcom:=StrCpt(buffer);
          until ( (length(strcom)>0) OR EOF(fp) ) ;
          if (length(strcom)>0) then
          Begin
{ Controlla la sintassi della riga }
          resasm := Controllo_Sintassi(strcom);
          if (not resasm) then
          Begin
             Writeln(buffer);
             Writeln('Errore di sintassi, riga: ',line);
          End
          else
          Begin
 { Ricerca l'istruzione nella prima riga della matrice }
               i:=0;
               ind := RicercaOpc( OpcLst[i],OpcLun[i],strcom);
 { Se non la trova passa alla seconda e terza riga }
               if (ind=0) then
               Begin
{ Scinde la parte statica dalla parte dinamica per ricercare nella matrice solo la prima }
                    ScindeStr(strcom,strsta,din);
                    while ( (i<2) and (ind=0) ) do
                    Begin
                         i:=i+1;
                         ind := RicercaOpc ( OpcLst[i],OpcLun[i],strsta );
                    End;
                End;
{ Se e' stata trovata l'istruzione nella matrice, ne memorizza gli opcode, e gli operandes nella memoria di assemblaggio }
                if (ind<>0) then
                Begin
{ Aggiorna l'indirizzo della memoria di assemblaggio }
                     w[1]:=MemInd mod 256;
                     w[0]:=MemInd div 256;
                     c:=MemInd;
{ Assembla la linea }
                     resasm := Assemblaggio( Mem, ind, i, din);
                     if (resasm) then
                     Begin
{ Aggiorna il numero di linee assemblate }
                            line:=line+1;
{ Stampa l'indirizzo dell'istruzione }
                            hex:=btoh(w[0]);
                            Write(hex);
                            hex:=btoh(w[1]);
                            Write(hex,' ');
{ Stampa gli opcodes e gli operandes dell'istruzione }
                            for i:=c to MemInd-1 do
                            Begin
                                 hex:=btoh(VM.Memory[i]);
                                 Write(hex,' ');
                            End;
{ Stampa l'istruzione sorgente }
                            Writeln(strcom);
                      End
                      else
                      Begin
{ Errore di overflow }
                           Writeln(buffer);
                           Writeln('Memoria di compilazione terminata');
                      End;
                End
                else
                Begin
{ Errore di 'ortografia' }
                     Writeln(buffer);
                     Writeln('Istruzione sconosciuta');
                End;
            End;
         End;
     End;
{ Termina restituendo il numero di linee assemblate }
     LoopASM:=line;
End;
