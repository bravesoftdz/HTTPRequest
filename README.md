# HTTP Request
Build a request using interfaces

# Usage

```pascal

function NewConnection(AMethod: THTTPMethods): IHTTPRequest<THTTPProcessorIdHTTP>;
begin
   Result :=  THTTPRequest<THTTPProcessorIdHTTP>.Create.Method(AMethod).Protocol(THTTPProtocols.spHTTP).Host('localhost').Port(8000).Route('/api');
end;

function GET: IHTTPRequest<THTTPProcessorIdHTTP>;
begin
   Result:= NewConnection(THTTPMethods.smGET);
end;

function POST: IHTTPRequest<THTTPProcessorIdHTTP>;
begin
   Result:= NewConnection(THTTPMethods.smPOST);
end;

```

example

```pascal

  TControllerAuthentication = class
  private
    { private declarations }
  HTTPRequest:IHTTPRequest<THTTPProcessorIdHTTP>;
  protected
    { protected declarations }
  public
    { public declarations }
    procedure Login(AEmail, APassword: string);
  published
    { published declarations }
  end;
  
implementation

procedure TControllerAuthentication.Login(AEmail, APassword: string);
begin

   HTTPRequest:=POST.Route(SERVER_AUTH_LOGIN)
    .Parameter('email', AEmail)
    .Parameter('password', APassword)
    .OnBefore(
    procedure
    begin
      //Before execute request
    end)
    .OnAfter(
    procedure(AResponse: TMemoryStream; AResponseCode: Integer)
    begin
      //After executing a request
    end)
    .OnException(
    procedure(E: Exception; AResponseCode: Integer)
    begin
      // If you have a request error
    end);
    
    HTTPRequest.Execute;
    
end;

```
