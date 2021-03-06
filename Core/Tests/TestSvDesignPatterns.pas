unit TestSvDesignPatterns;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Generics.Collections, SysUtils, SvDesignPatterns, Rtti, Classes;

type
  TSvStringList = class(TStringList)
  private
    FName: string;
    FValue: TSvStringList;
    [Inject] //will create stringlist
    FObj: TStringList;
    [Inject('100')]  //will assign 100 to FID
    FID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // Test methods for class TFactory
  {$HINTS OFF}
  //we dont need hints in our tests
  TestTFactory = class(TTestCase)
  private
    FFunc: TFactoryMethod<TSvStringList>;
    FFactory: TFactory<string, TSvStringList>;
    slList: TSvStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetInstance;
    procedure TestRegisterFactoryMethod;
    procedure TestUnregisterFactoryMethod;
    procedure TestUnregisterAll;
    procedure TestIsRegistered;
    procedure TestCreateElement;
    procedure TestGetEnumerator;
    procedure TestInject;
  end;
  // Test methods for class TMultiton

  TestTMultiton = class(TTestCase)
  private
    FMultiton: TMultiton<string, TSvStringList>;
    FFunc: TFactoryMethod<TSvStringList>;
    slList: TSvStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsRegistered;
    procedure TestRegisterFactoryMethod;
    procedure TestUnregisterFactoryMethod;
    procedure TestUnregisterAll;
    procedure TestGetEnumerator;
    procedure TestGetInstance;
    procedure TestGetDefaultInstance;
    procedure TestInject;
  end;

  TestTMultitonThreadSafe = class(TestTMultiton)
  public
    procedure SetUp; override;
  end;

  TestTSingleton = class(TTestCase)
  private
    FSingleton: TSingleton<TSvStringList>;
    FIntfSingleton: ISingleton<TSvStringList>;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetInstance;
  end;

  TestSvLazy = class(TTestCase)
  published
    procedure TestLazy;
  end;

implementation

procedure TestTFactory.SetUp;
var
  i: Integer;
begin
  FFactory := TFactory<string, TSvStringList>.Create;
  FFunc := function: TSvStringList begin Result := TSvStringList.Create end;
  slList := TSvStringList.Create;

  for i := 1 to 10 do
  begin
    slList.Add(IntToStr(i));
    FFactory.RegisterFactoryMethod(IntToStr(i),
      function: TSvStringList
      begin
        Result := TSvStringList.Create;
        Result.Add('5');
      end);
  end;

  slList.Sorted := True;
end;

procedure TestTFactory.TearDown;
var
  pair: TPair<string,TSvStringList>;
begin
{  for pair in FFactory do
  begin
    pair.Value.Free;
  end;  }
  FFactory.Free;
  FFactory := nil;
  slList.Free;
end;

procedure TestTFactory.TestCreateElement;
var
  sl: TSvStringList;
begin
  sl := nil;
  sl := FFactory.CreateElement;
  Check(Assigned(sl));
  CheckEquals(0, sl.Count);
  sl.Add('Temp');
  CheckEquals(1, sl.Count);
  sl.FObj.Free;
  sl.Free;
end;

procedure TestTFactory.TestGetEnumerator;
var
  pair: TPair<string,TSvStringList>;
begin
  for pair in FFactory do
  begin
    Check( slList.IndexOf(pair.Key) <> -1);
    Check(Assigned(pair.Value));
    CheckEquals(1, pair.Value.Count);
    pair.Value.Add('temp');
    CheckEquals(2, pair.Value.Count);
    pair.Value.FObj.Free;
    pair.Value.Free;
  end;
end;

procedure TestTFactory.TestGetInstance;
var
  ReturnValue: TSvStringList;
  AKey: string;
begin
  ReturnValue := nil;
  AKey := '5';
  ReturnValue := FFactory.GetInstance(AKey);
  Check(Assigned(ReturnValue));
  CheckEquals(AKey ,ReturnValue[0]);
  ReturnValue.FObj.Free;
  ReturnValue.Free;
end;

procedure TestTFactory.TestInject;
var
  i: Integer;
  obj, instance: TSvStringList;
begin
  obj := TSvStringList.Create;
  try
    obj.Add('Demo');
    //inject dynamically from code
    FFactory.InjectValue('5', 'FName', 'Demo');
    FFactory.InjectValue('5', 'FValue', obj);

    instance := FFactory.GetInstance('5');
    CheckEqualsString('Demo', instance.FName);
    CheckEqualsString('Demo', instance.FValue[0]);
    CheckEquals(100, instance.FID);

    CheckTrue(Assigned(instance.FObj));
    instance.FObj.Free;
    instance.Free;

    instance := FFactory.GetInstance('6');

    CheckFalse(Assigned(instance.FValue));
    CheckTrue(Assigned(instance.FObj));
    instance.FObj.Free;

    instance.Free;

  finally
    obj.Free;
  end;
end;

procedure TestTFactory.TestIsRegistered;
var
  AKey: string;
begin
  AKey := '4';
  CheckTrue(FFactory.IsRegistered(AKey));
  AKey := '15';
  CheckFalse(FFactory.IsRegistered(AKey));
end;

procedure TestTFactory.TestRegisterFactoryMethod;
begin
  CheckEquals(10, FFactory.Count);
  FFactory.RegisterFactoryMethod('test', FFunc);
  CheckEquals(11, FFactory.Count);
end;

procedure TestTFactory.TestUnregisterAll;
var
  pair: TPair<string,TSvStringList>;
begin
  CheckEquals(10, FFactory.Count);
  //free object to avoid memory leaks
  for pair in FFactory do
  begin
    pair.Value.FObj.Free;
    pair.Value.Free;
  end;
  FFactory.UnregisterAll;
  CheckEquals(0, FFactory.Count);
end;

procedure TestTFactory.TestUnregisterFactoryMethod;
var
  AKey: string;
  instance: TSvStringList;
begin
  CheckEquals(10, FFactory.Count);
  AKey := '5';
  instance := FFactory.GetInstance(AKey);
  instance.FObj.Free;
  instance.Free;
  FFactory.UnregisterFactoryMethod(AKey);
  CheckEquals(9, FFactory.Count);
end;

procedure TestTMultiton.SetUp;
var
  i: Integer;
begin
  FMultiton := TMultiton<string, TSvStringList>.Create(True);
  FFunc := function: TSvStringList begin Result := TSvStringList.Create end;
  slList := TSvStringList.Create;

  for i := 1 to 10 do
  begin
    slList.Add(IntToStr(i));
    FMultiton.RegisterFactoryMethod(IntToStr(i),
      function: TSvStringList
      begin
        Result := TSvStringList.Create;
        Result.Add('5');
      end);
  end;

  slList.Sorted := True;
end;

procedure TestTMultiton.TearDown;
begin
  FMultiton.Free;
  FMultiton := nil;
  slList.Free;
end;

procedure TestTMultiton.TestRegisterFactoryMethod;
var
  AKey: string;
begin
  CheckEquals(10, FMultiton.Count);
  AKey := '11';
  FMultiton.RegisterFactoryMethod(AKey, FFunc);
  CheckEquals(11, FMultiton.Count);
end;

procedure TestTMultiton.TestUnregisterFactoryMethod;
var
  AKey: string;
begin
  AKey := '5';
  CheckEquals(10, FMultiton.Count);
  FMultiton.UnregisterFactoryMethod(AKey);
  CheckEquals(9, FMultiton.Count);
end;

procedure TestTMultiton.TestUnregisterAll;
begin
  CheckEquals(10, FMultiton.Count);
  FMultiton.UnregisterAll;
  CheckEquals(0, FMultiton.Count);
end;

procedure TestTMultiton.TestGetDefaultInstance;
var
  AKey: string;
begin
  CheckEquals(10, FMultiton.Count);
  AKey := '11';
  FMultiton.RegisterFactoryMethod(AKey,
    function: TSvStringList
    begin
      Result := TSvStringList.Create;
      Result.Add('111');
    end);
  CheckEquals(11, FMultiton.Count);
  FMultiton.RegisterDefaultKey(AKey);
  CheckEqualsString('111', FMultiton.GetDefaultInstance[0]);
end;

procedure TestTMultiton.TestGetEnumerator;
var
  pair: TPair<string,TSvStringList>;
begin
  for pair in FMultiton do
  begin
    Check( slList.IndexOf(pair.Key) <> -1);
    Check(Assigned(pair.Value));
    CheckEquals(1, pair.Value.Count);
    pair.Value.Add('temp');
    CheckEquals(2, pair.Value.Count);
  end;
end;

procedure TestTMultiton.TestGetInstance;
var
  ReturnValue: TSvStringList;
  AKey: string;
begin
  AKey := '5';
  ReturnValue := nil;
  ReturnValue := FMultiton.GetInstance(AKey);
  CheckTrue(Assigned(ReturnValue));
  CheckEquals(AKey, ReturnValue[0]);
end;

procedure TestTMultiton.TestInject;
var
  i: Integer;
  obj, instance: TSvStringList;
begin
  obj := TSvStringList.Create;
  try
    obj.Add('Demo');
    //inject dynamically from code
    FMultiton.InjectValue('5', 'FName', 'Demo');
    FMultiton.InjectValue('5', 'FValue', obj);

    instance := FMultiton.GetInstance('5');
    CheckEqualsString('Demo', instance.FName);
    CheckEqualsString('Demo', instance.FValue[0]);
    CheckEquals(100, instance.FID);

    CheckTrue(Assigned(instance.FObj));
    instance := FMultiton.GetInstance('6');

    CheckFalse(Assigned(instance.FValue));
    CheckTrue(Assigned(instance.FObj));
  finally
    obj.Free;
  end;
end;

procedure TestTMultiton.TestIsRegistered;
var
  AKey: string;
begin
  AKey := '4';
  CheckTrue(FMultiton.IsRegistered(AKey));
  AKey := '15';
  CheckFalse(FMultiton.IsRegistered(AKey));
end;

{ TestTSingleton }

procedure TestTSingleton.SetUp;
var
  method: TFactoryMethod<TSvStringList>;
begin
  inherited;

  method := function: TSvStringList
    begin
      Result := TSvStringList.Create;
      Result.AddStrings(TArray<string>.Create('1','2','3'));
    end;

  FSingleton := TSingleton<TSvStringList>.Create;
  FIntfSingleton := TSingleton<TSvStringList>.Create(method);

  FSingleton.RegisterConstructor(method);
end;

procedure TestTSingleton.TearDown;
begin
  FSingleton.Free;
  inherited;
end;

procedure TestTSingleton.TestGetInstance;
var
  sl1, sl2: TSvStringList;
  singleton: ISingleton<TSvStringList>;
begin
  sl1 := nil;
  sl1 := FSingleton.GetInstance;
  CheckTrue(Assigned(sl1));
  CheckEquals(3, sl1.Count);
  CheckEqualsString('1', sl1[0]);
  CheckEqualsString('2', sl1[1]);
  CheckEqualsString('3', sl1[2]);
  sl2 := nil;
  sl2 := FIntfSingleton.GetInstance;
  CheckTrue(Assigned(sl2));
  CheckEquals(3, sl2.Count);
  CheckEqualsString('1', sl2[0]);
  CheckEqualsString('2', sl2[1]);
  CheckEqualsString('3', sl2[2]);
  //default constructor
  singleton := TSingleTon<TSvStringList>.Create();
  sl1 := nil;
  sl1 := singleton.GetInstance;
  CheckTrue(Assigned(sl1));
  sl1.AddStrings(TArray<string>.Create('1','2','3'));
  CheckEquals(3, sl1.Count);
  CheckEqualsString('1', sl1[0]);
  CheckEqualsString('2', sl1[1]);
  CheckEqualsString('3', sl1[2]);
end;



{ TestSvLazy }

procedure TestSvLazy.TestLazy;
var
  lazy1: SvLazy<TStrings>;
  lazy2: SvLazy<TStrings>;
  lazy3: SvLazy<TStrings>;
  lazy4: SvLazy<TStrings>;
  iCounter: Integer;
begin
  iCounter := 0;
  lazy1.Create(
    function: TStrings
    begin
      Result := TSvStringList.Create;
      Sleep(100);
      Result.Add('Test1');
      Inc(iCounter);
    end);

  lazy2.Create(
    function: TStrings
    begin
      Result := TSvStringList.Create;
      Sleep(100);
      Result.Add('Test2');
      Inc(iCounter);
    end);

  CheckEquals(0, iCounter);
  CheckTrue(Assigned(lazy1.Value));
  CheckEqualsString('Test1', lazy1.Value[0]);
  CheckEquals(1, iCounter);
  lazy1.Value.Free;

  CheckTrue(Assigned(lazy2.Value));
  CheckEqualsString('Test2', lazy2.Value[0]);
  CheckEquals(2, iCounter);
  lazy2.Value.Free;
  // create with aownsobjects = true. StringList will be freed when value goes out of scope
  lazy3.Create(
    function: TStrings
    begin
      Result := TSvStringList.Create;
      Sleep(100);
      Result.Add('Test3');
      Inc(iCounter);
    end, True);

  CheckTrue(Assigned(lazy3.Value));
  CheckEqualsString('Test3', lazy3.Value[0]);
  CheckEquals(3, iCounter);
  CheckTrue(lazy3.IsValueCreated);
  CheckFalse(lazy4.IsValueCreated);
end;
{$HINTS ON}
{ TestTMultitonThreadSafe }

procedure TestTMultitonThreadSafe.SetUp;
begin
  inherited;
  FMultiton.IsThreadSafe := True;
end;

{ TSvStringList }

constructor TSvStringList.Create;
begin
  inherited Create;
  FValue := nil;
  FName := '';
  FObj := nil;
end;

destructor TSvStringList.Destroy;
begin
  inherited;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFactory.Suite);
  RegisterTest(TestTMultiton.Suite);
  RegisterTest(TestTMultitonThreadSafe.Suite);
  RegisterTest(TestTSingleton.Suite);
  RegisterTest(TestSvLazy.Suite);
end.

