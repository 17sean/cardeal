program CarDealer;
uses crt;
type
    map = record
        w, h, x, y: integer;
    end;

    profile = record
        money: integer;
        cars: array [1..5] of integer;
    end;

    car = record
        idx, lux, price: integer;
        brand, model: string;
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

procedure Init(var m: map);
begin
    m.h := 20;
    m.w := 50;
    m.x := (ScreenWidth - m.w) div 2;
    m.y := (ScreenHeight - m.h) div 2;
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

procedure ErrMenu;
begin

end;

procedure DrawMainMenu;
begin
    clrscr;
end;

procedure DrawProfileMenu(m: map);
begin
    clrscr;
end;

procedure ProfileMenu(m: map);
var
    ch: char;
begin
    DrawProfileMenu(m);
end;

procedure DrawTradeMenu(m: map);
begin
    clrscr;
end;

procedure TradeMenu(m: map);
begin
    DrawTradeMenu(m);
end;

var
    m: map;
    p: profile;
    ch: char;
begin
    clrscr;
    ScreenCheck;
    randomize;
    Init(m, p);
    while true do
    begin
        DrawMainMenu;
        ch := ReadKey;
        case ch of
            '1': ProfileMenu(m);
            '2': TradeMenu(m);
            #27:
            begin
                clrscr;
                halt(0);
            end;
            else
                ErrMenu;
        end;
    end;
end.
