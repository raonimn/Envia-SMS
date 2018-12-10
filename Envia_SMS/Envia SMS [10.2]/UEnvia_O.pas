unit UEnvia_O;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.platform, fmx.helpers.android, androidapi.JNI.GraphicsContentViewText,
  androidapi.jni.JavaTypes, FMX.Objects, FMX.Controls.Presentation, Androidapi.Helpers;

type
  TEnvia_SMS = class(TForm)
    GbDia: TGroupBox;
    GbLanc: TGroupBox;
    GbMal: TGroupBox;
    Button1: TButton;
    Emsg: TLabel;
    Label2: TLabel;
    Emal: TEdit;
    SpeedButton1: TSpeedButton;
    RdiaS: TRadioButton;
    RdiaD: TRadioButton;
    RlancC: TRadioButton;
    RlancE: TRadioButton;
    RlancA: TRadioButton;
    Timer1: TTimer;
    imgLogo: TImage;
    lblOpera: TLabel;
    grpLogo: TGroupBox;
    function checar(): boolean;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure EmalChange(Sender: TObject);
    procedure RdiaSChange(Sender: TObject);
  private
    { Private declarations }
    ClipService: IFMXClipboardService;
    Elapsed: integer;
    function VerificaOperacao: string;
  public
    var
      dia, evento, mal: boolean;
      var
      malote, codigo: string;
    { Public declarations }
  end;

var
  Envia_SMS: TEnvia_SMS;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}
{$R *.LgXhdpiPh.fmx ANDROID}

uses
  Androidapi.NativeActivity, Androidapi.Jni.Telephony;

function TEnvia_SMS.VerificaOperacao: string;
var
  dAgora: string;
begin

  dAgora := FormatDateTime('yyyy/mm/dd', now);
  {***** ENCCEJA *****}
  if dAgora = '2018/08/05' then
    Result := 'ENCCEJA 2018'

  {***** ENEM *****}
  else if (dAgora = '2018/11/04') or (dAgora = '2018/11/11') then
    result := 'ENEM 2018'

{***** ENADE *****}
  else if (dAgora = '2018/11/25') then
    result := 'ENADE 2018'

{***** ENEM PPL *****}
  else if (dAgora = '2018/12/18') or (dAgora = '2018/12/19') then
    Result := 'ENEM PPL 2018'

{***** ENCCEJA PPL *****}
  else if (dAgora = '2018/09/18') or (dAgora = '2018/09/19') then
    Result := 'ENCCEJA PPL 2018'

{***** TESTE *****}
  else if (dAgora = '2018/06/15') then
    Result := 'MODO TESTE'
  else
    Result := '';

end;

procedure TEnvia_SMS.Button1Click(Sender: TObject);
var
  GerenciadorSMS: JSmsManager;
begin
  if lblOpera.Text = '' then
  begin
    ShowMessage('Não há operação cadastrada no dia de hoje - ' + formatdatetime('dd/mm/yyyy', now) + '. A mensagem não será enviada.');
  end
  else
  begin
    if (length(codigo) + Length(Emal.Text) = 13) then
    begin

      GerenciadorSMS := TJSmsManager.JavaClass.getDefault;
      GerenciadorSMS.sendTextMessage(StringToJString('28588'), nil, StringToJString(codigo + EMal.Text), nil, nil);
      showmessage('Enviando a mensagem ' + codigo + emal.Text + ' para o número 28588...');
      Emal.Text := '';
      Emsg.Text := '';
    end
    else
    begin
      showmessage('A mensagem não possui a quantidade correta de caracteres. Verifique o código do malote (apenas os números).' + Chr(13) + (codigo + Emal.Text));
    end;
  end;
end;

function TEnvia_SMS.checar(): boolean;
begin
  if (RdiaS.IsChecked) then
  begin
    if RlancE.IsChecked then
      codigo := '1101'
    else if RlancC.IsChecked then
      codigo := '1102'
    else if RlancA.IsChecked then
      codigo := '1105';
  end
  else
  begin
    if RlancE.IsChecked then
      codigo := '1103'
    else if RlancC.IsChecked then
      codigo := '1104'
    else if RlancA.IsChecked then
      codigo := '1105';
  end;
  if ((RdiaS.IsChecked) or (RdiaD.IsChecked)) then
    dia := true
  else
    dia := false;
  if ((RlancE.IsChecked) or (RlancC.IsChecked) or (RlancA.IsChecked)) then
    evento := true
  else
    evento := false;
  if length(Emal.Text) <> 9 then
    mal := false
  else
    mal := true;

  if (mal) and (evento) and (dia) then
  begin
    result := true;
    button1.Enabled := true;
    Emsg.Text := codigo + Emal.Text;
  end
  else
  begin
    result := false;
    Button1.Enabled := false;
    Emsg.Text := '';
  end;
end;

procedure TEnvia_SMS.EmalChange(Sender: TObject);
begin
  if length(Emal.Text) = 9 then
    checar;
end;

procedure TEnvia_SMS.FormActivate(Sender: TObject);
begin
  ClipService.SetClipboard('nil');
  lblOpera.Text := VerificaOperacao;
end;

procedure TEnvia_SMS.FormCreate(Sender: TObject);
begin
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(ClipService)) then
    ClipService := nil;

  Elapsed := 0;
  emal.MaxLength := 9;
end;

procedure TEnvia_SMS.RdiaSChange(Sender: TObject);
begin
  checar;
end;

procedure TEnvia_SMS.SpeedButton1Click(Sender: TObject);
var
  Intent: JIntent;
begin
  if assigned(ClipService) then
  begin
    clipservice.SetClipboard('nil');
    Intent := tjintent.Create;
    Intent.setAction(stringtojstring('com.google.zxing.client.android.SCAN'));
    SharedActivity.startActivityForResult(Intent, 0);
    Elapsed := 0;
    Timer1.Enabled := True;
  end;
end;

procedure TEnvia_SMS.Timer1Timer(Sender: TObject);
begin
  if (ClipService.GetClipboard.ToString <> 'nil') then
  begin
    timer1.Enabled := false;
    Elapsed := 0;
    Malote := clipservice.GetClipboard.ToString;
    if (Malote.Length = 13) then
    begin

      if (copy(malote, 1, 2) = 'IP') or (copy(malote, 1, 2) = 'IK') then
        Emal.Text := copy(malote, 3, 9)
    end
    else if (Malote.Length = 19) then
    begin

      if (copy(malote, 7, 2) = 'IP') or (copy(malote, 7, 2) = 'IK') then
        Emal.Text := copy(malote, 9, 9)
    end;

  end
  else
  begin
    if Elapsed > 9 then
    begin
      timer1.Enabled := false;
      Elapsed := 0;
    end
    else
      Elapsed := Elapsed + 1;
  end;
end;

end.

