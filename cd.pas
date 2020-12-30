program CarDealer;
uses crt;
const
    ProfileFile = 'profile.txt';
type
    map = record
        w, h, x, y: integer;
    end;

    profile = record
        m: longint; { money }
        c: array [1..5] of integer; { cars }
    end;

    cars = ^gamecar;
    gamecar = record
        idx, lux, price: integer;
        brand, model: string;
        next: cars;
    end;

procedure ScreenCheck();
begin
    if (ScreenWidth < 45) or (ScreenHeight < 18) then
    begin
        GotoXY((ScreenWidth - 25) div 2, (ScreenHeight-1) div 2);
        write('Resize terminal to 45x18');
        delay(5000);
        clrscr;
        halt(0);
    end;
end;

function fStI(s: string): longint; { from String to Integer } 
var
    i: integer;
    res: longint;
begin
    i := 1;
    res := 0;
    for i := 1 to length(s) do
    begin
        res *= 10;
        res += ord(s[i]) - ord('0');
    end;
    fStI := res;
end;

procedure CreateProfile(var p: profile);
begin

end;

procedure RewriteProfile(p: profile);
begin

end;

procedure ParseProfile(var p: profile);
var
    f: text;
    s: string;
    count: integer;
begin
    assign(f, ProfileFile);
    {$I-}
    reset(f);
    if IOresult <> 0 then
    begin
        CreateProfile(p);
        exit;
    end;
    {$I+}
    readln(f, s);
    if s = '' then
    begin
        CreateProfile(p);
        exit;
    end;

    p.m := fStI(s); { parse money }
    count := 1;
    while true do { parse cars } 
    begin
        readln(f, s);
        if s = '' then
            break;
        p.c[count] := fStI(s);
        count += 1;
    end;
end;


procedure ParseCars();
begin
end;

procedure Init(var m: map; var p: profile; var c: cars);
begin
    m.h := 20;
    m.w := 50;
    m.x := (ScreenWidth - m.w) div 2;
    m.y := (ScreenHeight - m.h) div 2;
    ParseProfile(p);
end;

function IsCar(c: cars; idx: integer): boolean; 
begin
    if idx = 0 then
    begin
        IsCar := false;
        exit;
    end;

    while c <> nil do
    begin
        if c^.idx = idx then
        begin
            IsCar := true;
            exit;
        end;
        c := c^.next;
    end;
    IsCar := false;
end;

function SearchByIdx(c: cars; idx: integer): gamecar;
begin
    if not IsCar(c, idx) then
    begin
        SearchByIdx := c^;
        exit;
    end;
    
    while c^.idx <> idx do
        c := c^.next;
    SearchByIdx := c^;
end;

function HaveCars(p: profile; c: cars): boolean;
var
    i: integer;
begin
    for i := 1 to 5 do
    begin
        if IsCar(c, p.c[i]) then
        begin
            HaveCars := true;
            exit;
        end;
    end;
    HaveCars := false;
end;

function SumCars(p: profile; c: cars): integer;
var
    i, sum: integer;
begin
    sum := 0;
    for i := 1 to 5 do
    begin
        if IsCar(c, p.c[i]) then
            sum += 1;
    end;
    SumCars := sum;
end;

procedure ShowMap(m: map);
var
    i, j: integer;
begin
    for i := 1 to m.h do
    begin
    GotoXY(m.x, m.y);
        write('|'); { default }
        for j := 2 to m.w-1 do
            write(' ');
        write('|');

        if i = 1 then { top }
        begin
            GotoXY(m.x, m.y);
            write(' ');
            for j := 2 to m.w-1 do
                write('_');
            write(' ');
        end;

        if i = m.h then { bottom }
        begin 
            GotoXY(m.x, m.y);
            write(' ');
            for j := 2 to m.w-1 do
                write('-');
            write(' '); 
        end;

        m.y += 1;
    end;
end;

procedure IntroScreen(m: map);
var
    i: integer;
    s: string;
begin
    clrscr;
    ShowMap(m);
    GotoXY((ScreenWidth - 10) div 2, ScreenHeight div 2);
    s := 'Car Dealer';
    for i := 1 to length(s) do
    begin
        write(s[i]);
        delay(100);
    end;
    delay(1000);
    clrscr;
end;

procedure ByeScreen;
begin
    clrscr;
    GotoXY((ScreenWidth - 3) div 2, ScreenHeight div 2);
    write('Bye');
    delay(750);
    clrscr;
    halt(0);
end;

procedure ErrMenu;
begin
    clrscr;
    GotoXY(
        (ScreenWidth - length('Error. Exiting...')) div 2,
        ScreenHeight div 2);
    write(ErrOutPut, 'Error. Exiting...');
    delay(3000);
    clrscr;
    halt(1);
end;

procedure DrawMainMenu(m: map);
var
    x, y: integer;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - 10) div 2;
    y := (ScreenHeight - 5) div 2;
    GotoXY(x, y);
    write('1. Profile');

    y += 1;
    GotoXY(x, y);
    write('2. Market');

    y += 2;
    GotoXY(x, y);
    write('Choose: ');
end;

procedure DrawProfileMenu(m: map; p: profile; c: cars);
var
    i, x, y: integer;
    tmpcar: gamecar;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - 15) div 2;
    y := (ScreenHeight - 10) div 2;
    GotoXY(x, y);
    write('Your Profile:');

    y += 2;
    GotoXY(x, y);
    write('Money: ', p.m);
    
    y += 1;
    GotoXY(x, y);
    write('Your cars:');

    if HaveCars(p, c) then
    begin
        for i := 1 to SumCars(p, c) do
        begin
            y += 1;
            tmpcar := SearchByIdx(c, p.c[i]);
            GotoXY(x, y);
            write(tmpcar.brand, ' ', tmpcar.model);
        end; 
    end;

    y += 2;
    x -= 1;
    GotoXY(x, y);
end;

procedure ProfileMenu(m: map; p: profile; c: cars);
var
    ch: char;
begin
    DrawProfileMenu(m, p, c);
    write('press q to quit');
    repeat
        ch := ReadKey;
    until ch in ['q', 'Q', #27];
    if ch = #27 then
        ByeScreen;
end;

procedure DrawTradeMenu(m: map);
begin
    clrscr;
end;

procedure TradeMenu(m: map; var p: profile; c: cars);
begin
    DrawTradeMenu(m);
end;

{ /todo}
var
    m: map;
    p: profile;
    c: cars;
    ch: char;
begin
    clrscr;
    ScreenCheck;
    randomize;
    Init(m, p, c);
    IntroScreen(m);
    while true do
    begin
        DrawMainMenu(m);
        repeat
            ch := ReadKey;
        until ch in ['1', '2', #27];
        case ch of
            '1': ProfileMenu(m, p, c);
            '2': TradeMenu(m, p, c);
            #27: ByeScreen;
            else
                ErrMenu;
        end;
    end;
end.
