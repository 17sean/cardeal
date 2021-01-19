unit engine;
interface
uses datstrc;

procedure Init(var m: map; var p: profile; var c: cars; var e: events);

procedure ScreenCheck();
procedure ErrScreen();
procedure ByeScreen();
procedure ShowMap(m: map);

procedure CreateProfile();
procedure RewriteProfile(p: profile);
procedure ParseProfile(var p: profile);
function PSumCars(p: profile; c: cars): integer; { Profile`s Sum of Cars }
function HaveCar(p: profile; idx: integer): boolean;
function HaveCarSlot(p: profile; idx: integer; var slot: integer): boolean;
function AnyEmptySlot(p: profile): integer;
procedure EmptySlot(var p: profile; slot: integer);

procedure ParseCars(var c: cars);
function SumCars(c: cars): integer;
function IsCar(c: cars; idx: integer; var car: gamecar): boolean;
function SearchCarByIdx(c: cars; idx: integer): gamecar;

procedure ParseEvents(var e: events);
function SumEvents(e: events): integer;
function IsEvent(e: events; idx: integer; var event: gameevent): boolean;
function SearchEventByIdx(e: events; idx: integer): gameevent;
function RandEvent(e: events): gameevent;

function FindMaxLux(p: profile; c: cars): integer;
function FindLuxExtra(lux: integer): longint;
function RandTradeList(p: profile; c: cars; event: gameevent): tradelist;
function FindSlotPrice(p: profile): longint;
function RandCasino(c: color): boolean;

procedure ProfileMenu(m: map; p: profile; c: cars);
procedure TradeMenu(m: map; var p: profile; c: cars; e: events);
procedure ShopMenu(m: map; var p: profile);
procedure CasinoMenu(m: map; var p: profile);

implementation
uses crt, slib, infc;
const
    ProfileFileName = 'data/profile.txt';
    CarsFileName = 'data/cars.txt';
    EventsFileName = 'data/events.txt';

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

procedure ByeScreen();
begin
    clrscr;
    halt(0);
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

procedure Init(var m: map; var p: profile; var c: cars; var e: events);
begin
    ScreenCheck;
    randomize;
    m.h := 20;
    m.w := 50;
    m.x := (ScreenWidth - m.w) div 2;
    m.y := (ScreenHeight - m.h) div 2;
    ParseProfile(p);
    ParseCars(c);
    ParseEvents(e);
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

function IsCar(c: cars; idx: integer; var car: gamecar): boolean;
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
            car := c^;
            exit;
        end;
        c := c^.next;
    end;
    IsCar := false;
end;

function SearchCarByIdx(c: cars; idx: integer): gamecar;
var
    car: gamecar;
begin
    if IsCar(c, idx, car) then
        SearchCarByIdx := car
    else
        SearchCarByIdx := c^;
end;

procedure ParseEvents(var e: events);
var
    f: text;
    s: string;
    tmp: events;
begin
    if not DFE(EventsFileName) then
        ErrScreen;

    e := nil;
    assign(f, EventsFileName);
    reset(f);
    while not EOF(f) do
    begin
        readln(f, s);
        case s[1] of
            '~':
            begin
                new(tmp);
                tmp^.next := e;
            end;
            ';': e := tmp;
            'I': tmp^.idx := SrI(ParserShorter(s));
            'B': tmp^.brand := ParserShorter(s);
            'O': tmp^.oper := ParserShorter(s)[1];
            'D': tmp^.diff := SrI(ParserShorter(s));
            'P': tmp^.per := SrI(ParserShorter(s));
            'S': tmp^.sit := ParserShorter(s);
            'M': tmp^.msg := ParserShorter(s);
        end;
    end;
    close(f);
end;

function SumEvents(e: events): integer;
var
    sum: integer;
begin
    sum := 0;
    while e <> nil do
    begin
        sum += 1;
        e := e^.next;
    end;
    SumEvents := sum;
end;

function IsEvent(e: events; idx: integer; var event: gameevent): boolean;
begin
    while e <> nil do
    begin
        if e^.idx = idx then
        begin
            IsEvent := true;
            event := e^;
            exit;
        end;
        e := e^.next;
    end;
    IsEvent := false;
end;

function SearchEventByIdx(e: events; idx: integer): gameevent;
var
    event: gameevent;
begin
    if IsEvent(e, idx, event) then
        SearchEventByIdx := event
    else
        SearchEventByIdx := e^;
end;

function PassEvent(event: gameevent): boolean;
type
    pChanceList = ^ChanceList;
    ChanceList = record
        data: boolean;
        next: pChanceList;
    end;
var
    i, count, rand: integer;
    cl, tmp: pChanceList; { Chance list }
begin
    if event.per = 0 then
    begin
        PassEvent := false;
        exit;
    end;

    cl := nil;
    count := 100 div event.per;
    for i := 1 to count do
    begin
        new(tmp);
        tmp^.next := cl;
        if i = 1 then
            tmp^.data := true
        else
            tmp^.data := false;
        cl := tmp;
    end;
    rand := random(count)+1;
    i := 1;
    while i <> rand do
    begin
        tmp := tmp^.next;
        i += 1;
    end;
    if tmp^.data = true then
        PassEvent := true
    else
        PassEvent := false;
    while cl <> nil do
    begin
        tmp := cl;
        cl := cl^.next;
        dispose(tmp);
    end;
end;

function RandEvent(e: events): gameevent;
var
    res, noevent: gameevent;
begin
    noevent.idx := 0;
    res := SearchEventByIdx(e, random(SumEvents(e))+1);
    if PassEvent(res) then
        RandEvent := res
    else
        RandEvent := noevent;
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
        if (p.c[i] > 0) and (SearchCarByIdx(c, p.c[i]).lux > lux) then
            lux := SearchCarByIdx(c, p.c[i]).lux;
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

function RandTradeList(p: profile; c: cars; event: gameevent): tradelist;
var
    i, sum, maxlux, status: integer; 
    car: gamecar;
    extra: longint;
    tl: tradelist;
begin
    sum := SumCars(c);
    maxlux := FindMaxLux(p, c);
    for i := 1 to 5 do
    begin
        repeat
            tl[i].idx := random(sum)+1;
        until SearchCarByIdx(c, tl[i].idx).lux <= maxlux;
        car := SearchCarByIdx(c, tl[i].idx);
        if (event.idx <> 0) and
           ((event.brand = car.brand) or
           (event.brand = 'ALL')) then
        begin
            case event.oper of
                '+': tl[i].price := car.price + event.diff;
                '-': tl[i].price := car.price - event.diff;
            end;
        end
        else
        begin
            extra := FindLuxExtra(car.lux);
            status := random(2);
            case status of
                0: tl[i].price := car.price + random(extra)+1;
                1: tl[i].price := car.price - random(extra)+1;
            end;
        end;
        tl[i].price := tl[i].price div 1000 * 1000;
    end;
    RandTradeList := tl;
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

function RandCasino(c: color): boolean;
var
    i: integer;
begin
    i := random(2);
    if ((c = r) and (i=0)) or
       ((c = b) and (i=1)) then
        RandCasino := true
    else
        RandCasino := false;
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

procedure TradeMenu(m: map; var p: profile; c: cars; e: events);
var
    tl: tradelist;
    ch: char;
    choise, slot: integer;
    event: gameevent;
begin
    event := RandEvent(e);
    tl := RandTradeList(p, c, event);
    DrawTradeMenu(m, p, c, event, tl, 0);
    repeat
        ch := ReadKey;
    until ch in ['1'..'5', 'q', 'Q'];
    if ch in ['q', 'Q'] then
        exit;
    choise := ord(ch) - ord('0');
    DrawTradeMenu(m, p, c, event, tl, choise);
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
    TradeMenu(m, p, c, e);
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

procedure CasinoMenu(m: map; var p: profile);
var
    ch: char;
    c: color;
    bet: longint;
begin
    DrawCasinoMenu(m, p, 0);
    repeat
        ch := ReadKey;
    until ch in ['r', 'R', 'b', 'B', 'q', 'Q'];
    case ch of
    'r', 'R': c := r;
    'b', 'B': c := b;
    'q', 'Q': exit;
    end;
    DrawCasinoMenu(m, p, 1);
    repeat
        ch := ReadKey;
    until ch in ['1', '2', '3', '4', '5', 'q', 'Q'];
    case ch of
    '1': bet := 50000;
    '2': bet := 100000;
    '3': bet := 250000;
    '4': bet := 500000;
    '5': bet := 1000000;
    'q', 'Q': exit;
    end;
    if bet > p.m then
    begin
        write('Not enough money');
        delay(1000);
        exit;
    end;
    if RandCasino(c) then
    begin
        p.m += bet;
        DrawCasinoMenu(m, p, 2);
    end
    else
    begin
        p.m -= bet;
        DrawCasinoMenu(m, p, 3);
    end;
    delay(1000);
    RewriteProfile(p);
    CasinoMenu(m, p);
end;

end.
