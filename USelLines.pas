unit USelLines;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OpWString, ExtCtrls, Vcl.ComCtrls{, SDL_geoatlas};

type
  TForm1 = class(TForm)
    GoButton: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    EditFileName: TEdit;
    CheckBox1: TCheckBox;
    RadioGroup1: TRadioGroup;
    RadioButtonSingleText: TRadioButton;
    RadioButtonFile: TRadioButton;
    EditTekst: TEdit;
    OpenDialogSearchTextFile: TOpenDialog;
    GroupBox1: TGroupBox;
    EditNotContaining: TEdit;
    RichEdit1: TRichEdit;
    procedure SelectFileButtonClick(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure EditTekstClick(Sender: TObject);
    procedure EditFileNameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.SelectFileButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    EditFileName.Text := ExpandFileName( OpenDialog1.FileName );
  end;

end;

procedure TForm1.GoButtonClick(Sender: TObject);
  var
    f, g, h, l: TextFile;
    Regel: String;
    i, j, Len, Number, PrevNumber: Integer;
    IsWritten: Boolean;
Const
    WordDelims = [' ',',',';'];
Function IsInFile( const Regel: string ): Integer;
var
  atextLine, atext: string;
  k: Integer;
begin
  Reset( h );
  j := 0;
  repeat
    if not EOF( h ) then begin
      Readln( h, atextLine );  Trim( atextLine );
      {atext := Trim( ExtractWord( 1, atextLine, WordDelims, Len ) );}
      {if ( Len > 0 ) then begin}
        j := pos( atextLine, Regel );
        k := pos( EditNotContaining.text, Regel );
        if k>0 then
          j := 0;
      {end;}
    end;
  until ( j = 1 ) or EOF( h );
  Result := j;
end; {-Function IsInFile}

begin
  SaveDialog1.FileName := JustName( EditFileName.Text  ) + '_result.txt';
  if SaveDialog1.Execute then begin
    i := 0;
    Try
      AssignFile( f, Trim( EditFileName.Text ) ); Reset( f );
      AssignFile( g, SaveDialog1.FileName ); Rewrite( g );
      AssignFile( l, extractFileDir( SaveDialog1.FileName ) + '\notIn' + extractFileName( SaveDialog1.FileName ) ); Rewrite( l );
      if RadioButtonFile.Checked then begin
        AssignFile( h, Trim( EditTekst.Text ) ); Reset( h );
      end;
      PrevNumber := 0;
      while ( not EOF( f ) ) do begin
        Readln( f, Regel );
        if RadioButtonSingleText.Checked then
          j := pos( EditTekst.Text, Regel )
        else
          j := IsInfile( Regel );
        Regel := Regel.Replace( ',', #9);

        IsWritten := false;
        if j > 0 then begin
          if ( not CheckBox1.Checked ) then begin


            Writeln( g, Regel ); IsWritten := true;
            Inc( i );

            {TIJDELIJK}
           { Regel := ' 0.779783191088E+01 0.777998108872E+01 0.777104750684E+01 0.774135798025E+01';
            Writeln( l, Regel );}
            {TIJDELIJK}

          end else begin
            Number :=  StrToInt( ExtractWord( 3, Regel, WordDelims, Len ) );
            if ( i = 0 ) then begin
              PrevNumber := Number;
              Inc( i );
              Writeln( g, Regel ); IsWritten := true;
            end else begin
              if ( Number > PrevNumber ) then begin
                PrevNumber := Number;
                Inc( i );
                Writeln( g, Regel ); IsWritten := true;
              end;
            end;
          end;
        end;
        if not IsWritten then
          Writeln( l, Regel );

      end;
    Finally

      CloseFile( f );
      CloseFile( g );
      CloseFile( l );
      if RadioButtonFile.Checked then
        Closefile( h );
      RichEdit1.Lines.LoadFromFile(SaveDialog1.FileName);
      RichEdit1.SelectAll; RichEdit1.CopyToClipboard;
      ShowMessage( 'Nr of lines written: ' + IntToStr( i ) );
    end;
  end;
end;


procedure TForm1.EditFileNameClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    EditFileName.Text := ExpandFileName( OpenDialog1.FileName );
  end;
end;

procedure TForm1.EditTekstClick(Sender: TObject);
begin
  if RadioButtonFile.Checked then begin
    with OpenDialogSearchTextFile do begin
      if execute then begin
        EditTekst.Text := expandfilename( filename );
      end;
    end;
  end;

end;

begin
 with FormatSettings do begin {-Delphi XE6}
  Decimalseparator := '.';
 end;
end.
