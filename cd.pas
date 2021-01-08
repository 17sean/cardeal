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
        s: integer; { slots }
        c: array [1..5] of integer; { cars }
    end;

    cars = ^gamecar;
    gamecar = record
        idx, lux: integer;
        price: longint;
        brand, model: string;
        next: cars;
    end;

    tradelistelement = record
        idx: integer;
        price: longint;
    end;
    tradelist = array [1..5] of tradelistelement;

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

procedure ErrScreen();
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

procedure IntroScreen();
var
    i: integer;
    s: string;
begin
    clrscr;
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

procedure ByeScreen();
begin
    clrscr;
    GotoXY((ScreenWidth - 3) div 2, ScreenHeight div 2);
    write('Bye');
    delay(750);
    clrscr;
    halt(0);
end;

function SrI(s: string): longint; { String returns Integer }
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
    SrI := res;
end;

function IrS(i: longint): string; { Integer returns string }
type
    pIntEl = ^IntEl;
    IntEl = record
        data: char;
        next: pIntEl;
    end;
var
    p, tmp: pIntEl;
    s: string;
    j: longint;
begin
    if i = 0 then
    begin
        IrS := '0';
        exit;
    end;

    p := nil;
    s := ''; 
    j := i;
    if i < 0 then
        i := -i;
    while i <> 0 do
    begin
        new(tmp);
        if (i mod 10) <> 0 then
            tmp^.data := chr(ord(i mod 10) + ord('0'))
        else
            tmp^.data := '0';
        i := i div 10;
        tmp^.next := p;
        p := tmp;
    end;
    if j < 0 then
        s += '-';
    while tmp <> nil do
    begin
        s += tmp^.data;
        tmp := tmp^.next;
    end;
    while p <> nil do
    begin
        tmp := p;
        p := p^.next;
        dispose(tmp);
    end;
    IrS := s;
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

procedure CreateProfile();
var
    f: text;
    defmoney: longint; { Default money }
    defslots, defcar: integer;   { Default car }
    count: integer;
begin
    defmoney := 15000;
    defslots := 1;
    defcar := 1;
    assign(f, ProfileFileName);
    rewrite(f);
    count := 1;
    while count <> 8 do
    begin
        case count of
            1: writeln(f, 'M:' + IrS(defmoney));
            2: writeln(f, 'S:' + IrS(defslots));
            3: writeln(f, IrS(count-2) + ':' + IrS(defcar));
            4..7: writeln(f, IrS(count-2) + ':' + IrS(0));
        end;
        count += 1;
    end;
    close(f);
end;

procedure RewriteProfile(p: profile);
var
    f: text;
    count: integer;
begin
    assign(f, ProfileFileName);
    rewrite(f);
    count := 1;
    while count <> 8 do
    begin
        case count of
            1: writeln(f, 'M:' + IrS(p.m)); 
            2: writeln(f, 'S:' + IrS(p.s));
            3..7: writeln(f, IrS(count-2) + ':' + IrS(p.c[count-2]));
        end;
        count += 1;
    end;
    close(f);
end;

procedure ParseProfile(var p: profile);
var
    f: text;
    s: string;
begin
    if not DFE(ProfileFileName) then
        CreateProfile;

    assign(f, ProfileFileName);
    reset(f);
    while not EOF(f) do
    begin
        readln(f, s);
        case s[1] of
            'M': p.m := SrI(ParserShorter(s));
            'S': p.s := SrI(ParserShorter(s));
            '1'..'5': p.c[SrI(s[1])] := SrI(ParserShorter(s));
        end;
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

    c := nil;
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

            'I': tmp^.idx := SrI(ParserShorter(s));
            'B': tmp^.brand := ParserShorter(s);
            'M': tmp^.model := ParserShorter(s);
            'L': tmp^.lux := SrI(ParserShorter(s));
            'P': tmp^.price := SrI(ParserShorter(s));
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

function HaveCar(p: profile; idx: integer): boolean;
var
    i: integer;
begin
    for i := 1 to p.s do
    begin
        if p.c[i] = idx then
        begin
            HaveCar := true;
            exit;
        end;
    end;
    HaveCar := false;
end;

function HaveCarSlot(p: profile; idx: integer; var slot: integer): boolean;
var
    i: integer;
begin
    for i := 1 to p.s do
    begin
        if p.c[i] = idx then
        begin
            HaveCarSlot := true;
            slot := i;
            exit;
        end;
    end;
    HaveCarSlot := false;
end;

function PSumCars(p: profile; c: cars): integer; { Profile`s Sum of Cars }
var
    i, sum: integer;
begin
    sum := 0;
    for i := 1 to p.s do
    begin
        if p.c[i] > 0 then
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

function AnyEmptySlot(p: profile): integer;
var
    i: integer;
begin
    for i := 1 to p.s do
    begin
        if p.c[i] = 0 then
        begin
            AnyEmptySlot := i;
            exit;
        end;
    end;
    AnyEmptySlot := 0;
end;

procedure EmptySlot(var p: profile; slot: integer);
begin
    p.c[slot] := 0;
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
    write('1) Profile');

    y += 1;
    GotoXY(x, y);
    write('2) Market');

    y += 1;
    GotoXY(x, y);
    write('3) Shop');

    y += 2;
    GotoXY(x, y);
    write('n) New game');

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
    x := (ScreenWidth - 7) div 2;
    y := (ScreenHeight - 14) div 2;
    GotoXY(x, y);
    write('Profile');

    x := (ScreenWidth - (length('Money: ') + length(IrS(p.m)))) div 2;
    y += 3;
    GotoXY(x, y);
    write('Money: ', p.m);
    

    x := (ScreenWidth - 7) div 2;
    y += 2;
    GotoXY(x, y);
    write('Garage:');

    x -= 3;
    y += 1;
    for i := 1 to p.s do
    begin
        y += 1;
        GotoXY(x, y);
        if p.c[i] > 0 then
        begin
            tmpcar := SearchByIdx(c, p.c[i]);
            write(tmpcar.brand, ' ', tmpcar.model);
        end
        else
            write('-');
    end;

    x -= 1;
    y += 2;
    GotoXY(x, y);
    write('press q to quit');
end;

procedure ProfileMenu(m: map; p: profile; c: cars);
var
    ch: char;
begin
    DrawProfileMenu(m, p, c);
    repeat
        ch := ReadKey;
    until ch in ['q', 'Q'];
end;

function FindMaxLux(p: profile; c: cars): integer;
var
    i, lux: integer;
begin
    lux := 0;
    case p.m of
        0..50000: lux := 1;
        50001..100000: lux := 2;
        100001..250000: lux := 3;
        250001..500000: lux := 4;
        500001..2000000000: lux := 5;
    end;
    for i := 1 to p.s do
    begin
        if (p.c[i] > 0) and (SearchByIdx(c, p.c[i]).lux > lux) then
            lux := SearchByIdx(c, p.c[i]).lux;
    end;
    FindMaxLux := lux;
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

function RandTradeList(p: profile; c: cars): tradelist;
var
    i, sum, maxlux, status: integer; 
    extra: longint;
    tl: tradelist;
begin
    sum := SumCars(c);
    maxlux := FindMaxLux(p, c);
    for i := 1 to 5 do
    begin
        repeat
            tl[i].idx := random(sum)+1;
        until SearchByIdx(c, tl[i].idx).lux <= maxlux;
        extra := FindLuxExtra(SearchByIdx(c, tl[i].idx).lux);
        status := random(2);
        case status of
            0: tl[i].price := SearchByIdx(c, tl[i].idx).price +
                                                        random(extra)+1;
            1: tl[i].price := SearchByIdx(c, tl[i].idx).price - 
                                                        random(extra)+1;
        end;
        tl[i].price := tl[i].price div 1000 * 1000;
    end;
    RandTradeList := tl;
end;

procedure DrawTradeMenu(
                        m: map;
                        p: profile;
                        c: cars;
                        tl: tradelist;
                        choise: integer);
var
    x, y, i: integer;
    tmpcar: gamecar;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - length('Market')) div 2;
    y := (ScreenHeight - 14) div 2;
    GotoXY(x, y);
    write('Market');

    y += 3;
    GotoXY(x, y);
    write('Offers');

    x := (ScreenWidth - 27) div 2;
    y += 1;
    for i := 1 to 5 do
    begin
        tmpcar := SearchByIdx(c, tl[i].idx);
        y += 1;
        GotoXY(x, y);
        if HaveCar(p, tmpcar.idx) then
            write(#8#8'+ ');
        write(
              i, ') ',
              tmpcar.brand,' ', tmpcar.model, ' ', tl[i].price);
    end;

    case choise of
        0:
        begin
            x := (ScreenWidth - length('Enter car`s number')) div 2;
            y += 2;
            GotoXY(x, y);
            write('Enter car`s number');
        end;
        else
        begin
            x := (ScreenWidth - 27) div 2;
            y -= (5 - choise);
            GotoXY(x, y);
            write('* ');

            x := (ScreenWidth - length('Press b/s buy/sell')) div 2;
            y += (7 - choise); 
            GotoXY(x, y);
            write('Press b/s buy/sell');
        end;
    end;

    y += 1;
    GotoXY(x, y);
end;

procedure TradeMenu(m: map; var p: profile; c: cars);
var
    tl: tradelist;
    ch: char;
    choise, slot: integer;
begin
    tl := RandTradeList(p, c);
    DrawTradeMenu(m, p, c, tl, 0);
    repeat
        ch := ReadKey;
    until ch in ['1'..'5', 'q', 'Q'];
    if ch in ['q', 'Q'] then
        exit;
    choise := ord(ch) - ord('0');

    DrawTradeMenu(m, p, c, tl, choise);
    repeat
        ch := ReadKey;
    until ch in ['b', 's', 'q', 'Q'];
    case ch of
        'b':
        begin
            if (AnyEmptySlot(p) <> 0)
            and ((p.m - tl[choise].price) >= 0) then
            begin
                p.c[AnyEmptySlot(p)] := tl[choise].idx;
                p.m -= tl[choise].price;
                write('Success');
            end
            else if AnyEmptySlot(p) = 0 then
                write('No empty slot')
            else if (p.m - tl[choise].price) < 0 then
                write('Not enough money');
        end;
        's':
        begin
            if HaveCarSlot(p, tl[choise].idx, slot) then
            begin
                EmptySlot(p, slot);
                p.m += tl[choise].price;
                write('Success');
            end
            else
                write('You haven`t this car');
        end;
        'q', 'Q': exit;
    end;
    delay(1500);
    RewriteProfile(p);
    TradeMenu(m, p, c);
end;

function FindSlotPrice(p: profile): longint;
begin
    case p.s of
        1: FindSlotPrice := 50000;
        2: FindSlotPrice := 150000;
        3: FindSlotPrice := 350000;
        4: FindSlotPrice := 1000000;
    end;
end;

procedure DrawShopMenu(m: map; p: profile; price: longint);
var
    x, y: integer;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - 4) div 2;
    y := (ScreenHeight - 8) div 2;
    GotoXY(x, y);
    write('Shop');

    y += 3;
    if p.s <> 5 then
    begin
        x -= 15 - length(IrS(price));
        GotoXY(x, y);
        write('1) Buy new slot ', price)
    end
    else
    begin
        x := (ScreenWidth - length('You bought all slots')) div 2;
        GotoXY(x, y);
        write('You bought all slots');
    end;

    x := (ScreenWidth - length('press q to quit')) div 2;
    y += 4;
    GotoXY(x, y);
    write('press q to quit');
end;

procedure ShopMenu(m: map; var p: profile);
var
    ch: char;
    price: longint;
begin
    price := FindSlotPrice(p);
    DrawShopMenu(m, p, price);
    repeat
        ch := ReadKey;
    until ch in ['1', 'q', 'Q'];
    case ch of
        '1':
        begin
            if (p.s <> 5) and ((p.m - price) > 0) then
            begin
                p.s += 1;
                p.m -= price;
                RewriteProfile(p);
            end;
        end;
        'q', 'Q': exit;
    end;
end;

var
    m: map;
    p: profile;
    c: cars;
    ch: char;
begin
    clrscr;
    randomize;
    ScreenCheck;
    IntroScreen;
    Init(m, p, c);
    while true do
    begin
        DrawMainMenu(m);
        repeat
            ch := ReadKey;
        until ch in ['1', '2', '3', 'n', 'N', 'q', 'Q'];
        case ch of
            '1': ProfileMenu(m, p, c);
            '2': TradeMenu(m, p, c);
            '3': ShopMenu(m, p);
            'n', 'N':
            begin
                CreateProfile;
                ParseProfile(p);
            end;
            'q', 'Q': ByeScreen;
        end;
    end;
end.
