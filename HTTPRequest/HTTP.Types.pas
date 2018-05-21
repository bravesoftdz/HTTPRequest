unit HTTP.Types;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes;

type

  THTTPProcBeforeExecute = reference to procedure;
  THTTPProcAfterExecute = reference to procedure(AResponse: TMemoryStream; AResponseCode: Integer);
  THTTPProcException = reference to procedure(E: Exception; AResponseCode: Integer);

  THTTPProtocols = (spHTTP, spHTTPS);
  THTTPMethods = (smGET, smPOST, smPUT, smDELETE);
  THTTPStrParameters = TDictionary<string, string>;
  THTTPFiles = TDictionary<string, string>;
  THTTPStrHeaders = TDictionary<string, string>;

  THTTPOnBeforeList = TList<THTTPProcBeforeExecute>;
  THTTPOnAfterList = TList<THTTPProcAfterExecute>;
  THTTPOnExceptionList = TList<THTTPProcException>;

implementation

end.
