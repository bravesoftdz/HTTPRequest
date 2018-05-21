unit HTTP.Interfaces;

interface

uses HTTP.Types, System.Classes;

type

  IHTTPProcessor = interface;
  IHTTPRequest<T: IHTTPProcessor> = interface;

  IHTTPProcessor = interface
    ['{501FC362-6A99-4FBD-8ECF-2071246877D9}']
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: Integer);
    procedure SetProtocol(const Value: THTTPProtocols);
    procedure SetRoutes(const Value: TStringList);
    function GetHost: string;
    function GetPort: Integer;
    function GetProtocol: THTTPProtocols;
    function GetRoutes: TStringList;
    procedure SetMethod(const Value: THTTPMethods);
    function GetMethod: THTTPMethods;
    procedure SetHeaders(const Value: THTTPStrHeaders);
    function GetHeaders: THTTPStrHeaders;
    procedure SetParameters(const Value: THTTPStrParameters);
    function GetParameters: THTTPStrParameters;
    procedure SetAfterList(const Value: THTTPOnAfterList);
    procedure SetBeforeList(const Value: THTTPOnBeforeList);
    procedure SetRExceptionList(const Value: THTTPOnExceptionList);
    function GetAfterList: THTTPOnAfterList;
    function GetBeforeList: THTTPOnBeforeList;
    function GetRExceptionList: THTTPOnExceptionList;
    procedure SetFiles(const Value: THTTPFiles);
    function GetFiles: THTTPFiles;

    property Method:THTTPMethods read GetMethod write SetMethod;
    property Protocol: THTTPProtocols read GetProtocol write SetProtocol;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property Routes: TStringList read GetRoutes write SetRoutes;
    property Headers: THTTPStrHeaders read GetHeaders write SetHeaders;
    property Parameters: THTTPStrParameters read GetParameters write SetParameters;
    property Files: THTTPFiles read GetFiles write SetFiles;
    property BeforeList: THTTPOnBeforeList read GetBeforeList write SetBeforeList;
    property AfterList: THTTPOnAfterList read GetAfterList write SetAfterList;
    property RExceptionList: THTTPOnExceptionList read GetRExceptionList write SetRExceptionList;

    procedure Execute;
  end;

  IHTTPRequest<T: IHTTPProcessor> = interface
    ['{BE33C9AF-B0B0-4933-BAC3-7A0AD4A6BBBA}']
    function Method(AMethod: THTTPMethods): IHTTPRequest<T>;
    function Protocol(AProtocol: THTTPProtocols): IHTTPRequest<T>;
    function Host(AHost: string): IHTTPRequest<T>;
    function Port(APort: Integer): IHTTPRequest<T>;
    function Route(ARoute: string): IHTTPRequest<T>;
    function Header(AKey, AValue: string): IHTTPRequest<T>;
    function Parameter(AKey, AValue: string): IHTTPRequest<T>;
    function &File(AKey, AFileName: string): IHTTPRequest<T>;

    function OnAfter(AProcAfterExecute: THTTPProcAfterExecute): IHTTPRequest<T>;
    function OnBefore(AProcBeforeExecute: THTTPProcBeforeExecute): IHTTPRequest<T>;
    function OnException(AProcException: THTTPProcException): IHTTPRequest<T>;

    procedure Execute;

  end;

implementation

end.
