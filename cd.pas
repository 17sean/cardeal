program CarDealer;
uses crt;
const
    ProfileFileName = 'profile.txt';
    CarsFileName = 'cars.txt';
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
        idx, lux: integer;
        price: longint;
        brand, model: string;
        next: cars;
    end;

    gametradeelement = record
        car, idx: integer;
        price: longint;
    end;
    gametradelist = array [1..5] of gametradeelement;

    binstatus = (a, b);

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

procedure ErrScreen;
begin
    clrscr;
    GotoXY(
        (ScreenWidth - length('Error. Exiting...')) div 2,
        ScreenHeight div 2);
    write(ErrOutput, 'Error. Exiting...');
    delay(3000);
    clrscr;
    halt(1);
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

function StringShorter(s: string; pos: integer): string;
var
    tmp: string;
    i: integer;
begin
    tmp := '';
    for i := pos to length(s) do
        tmp += s[i];
    StringShorter := tmp;
end;

function ParserShorter(s: string): string;
var
    pos: integer;
begin
    pos := 1;
    while s[pos] <> ':' do
        pos += 1;
    ParserShorter := StringShorter(s, pos+1);
end;

function DFE(dir: string): boolean; { Does file exist? }
var
    f: file;
begin
    assign(f, dir);
    {$I-}
    reset(f);
    if IOresult = 0 then
    begin
        DFE := true;
        close(f);
        {$I+}
        exit;
    end
    else
        DFE := false;
    {$I+}
end;

procedure CreateProfile(var p: profile);
var
    f: text;
    i: integer;
begin
    assign(f, ProfileFileName);
    rewrite(f);

    writeln(f, '10000'); { Give money }
    writeln(f, '1'); { Give first car }
    for i := 1 to 4 do { Init other cars  }
    begin
        if i <> 4 then
            writeln(f, '0')
        else
            write(f, '0');
    end;
    close(f);
end;

procedure RewriteProfile(p: profile);
var
    f: text;
    i: integer;
begin
    assign(f, ProfileFileName);
    rewrite(f);
    writeln(f, p.m);
    for i := 1 to 5 do
    begin
        if i <> 5 then
            writeln(f, p.c[i])
        else
            write(f, p.c[i]);
    end;
    close(f);
end;

procedure ParseProfile(var p: profile);
var
    f: text;
    s: string;
    count: integer;
begin
    assign(f, ProfileFileName);
    if not DFE(ProfileFileName) then
        CreateProfile(p);
    reset(f);
    readln(f, s);
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
    close(f);
end;

procedure ParseCars(var c: cars);
var
    f: text;
    s: string;
    tmp: cars;
begin
    if not DFE(CarsFileName) then
        ErrScreen;

    c := nil; { Initialization } 
    assign(f, CarsFileName);
    reset(f);
    while not EOF(f) do
    begin
        readln(f, s);
        case s[1] of
            '~':
            begin
                new(tmp);
                tmp^.next := c;
            end;
            ';': c := tmp;

            'I': tmp^.idx := fStI(ParserShorter(s));
            'B': tmp^.brand := ParserShorter(s);
            'M': tmp^.model := ParserShorter(s);
            'L': tmp^.lux := fStI(ParserShorter(s));
            'P': tmp^.price := fStI(ParserShorter(s));
        end;
    end;
    close(f);
end;

procedure Init(var m: map; var p: profile; var c: cars);
begin
    m.h := 20;
    m.w := 50;
    m.x := (ScreenWidth - m.w) div 2;
    m.y := (ScreenHeight - m.h) div 2;
    ParseProfile(p);
    ParseCars(c);
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

function PSumCars(p: profile; c: cars): integer;
var
    i, sum: integer;
begin
    sum := 0;
    for i := 1 to 5 do
    begin
        if IsCar(c, p.c[i]) then
            sum += 1;
    end;
    PSumCars := sum;
end;

function SumCars(c: cars): integer;
var
    sum: integer;
begin
    sum := 0;
    while c <> nil do
    begin
        sum += 1;
        c := c^.next;
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
        for i := 1 to PSumCars(p, c) do
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

function FindProfileLux(p: profile): integer;
begin
    case p.m of
        0..50000: FindProfileLux := 1;
        50001..100000: FindProfileLux := 2;
        100001..250000: FindProfileLux := 3;
        250001..500000: FindProfileLux := 4;
        500001..1000000: FindProfileLux := 5;
    end;
end;

function FindLuxExtra(lux: integer): longint;
begin
    case lux of
        1: FindLuxExtra := 6000;
        2: FindLuxExtra := 15000;
        3: FindLuxExtra := 35000;
        4: FindLuxExtra := 70000;
        5: FindLuxExtra := 250000;
    end;
end;

function RandTradeList(p: profile; c: cars): gametradelist;
var
    i, sum, plux, status: integer;
    extra: longint;
    tmp: gametradelist;
    tmpcar: gamecar;
begin
    plux := FindProfileLux(p);
    sum := SumCars(c);
    for i := 1 to 5 do
    begin
        tmp[i].idx := i;
        repeat
        tmp[i].car := random(sum)+1;
        tmpcar := SearchByIdx(c, tmp[i].car);
        until tmpcar.lux <= plux;
        extra := FindLuxExtra(tmpcar.lux);
        status := random(2);
        case status of
            0: tmp[i].price := tmpcar.price + random(extra)+1;
            1: tmp[i].price := tmpcar.price - random(extra)+1;
        end;
        tmp[i].price := tmp[i].price div 1000 * 1000;
    end;
    RandTradeList := tmp;
end;

procedure DrawTradeMenu(
                        m: map;
                        c: cars;
                        tradelist: gametradelist;
                        status: binstatus);
var
    x, y, i: integer;
    tmpcar: gamecar;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - length('Market')) div 2;
    y := (ScreenHeight - 15) div 2;
    GotoXY(x, y);
    write('Market');

    y += 3;
    GotoXY(x, y);
    write('Offers');

    y += 1;
    x -= 10;
    for i := 1 to 5 do
    begin
        tmpcar := SearchByIdx(c, tradelist[i].car);
        y += 1;
        GotoXY(x, y);
        write(
            tradelist[i].idx, '. ',
            tmpcar.brand, ' ',
            tmpcar.model, ' ',
            tradelist[i].price);
    end;

    y += 2;
    x := (ScreenWidth - length('Enter car`s number')) div 2;
    case status of 
        a:
        begin
            GotoXY(x, y);
            write('Enter car`s number');
        end;
        b:
        begin
            GotoXY(x, y);
            write('Press b/s buy/sell');
        end;
    end;
end;

{ todo }

procedure TradeMenu(m: map; var p: profile; c: cars);
var
    tradelist: gametradelist;
begin
    tradelist := RandTradeList(p, c);
    DrawTradeMenu(m, c, tradelist, a);
    
    delay(1000);

    DrawTradeMenu(m, c, tradelist, b);

    delay(1000);
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
                ErrScreen;
        end;
    end;
end.
