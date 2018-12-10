program Enviar_SMS;

uses
  System.StartUpCopy,
  FMX.Forms,
  UEnvia_O in 'UEnvia_O.pas' {Envia_SMS};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TEnvia_SMS, Envia_SMS);
  Application.Run;
end.
