unit infc;
interface
uses datstrc;

procedure ErrScreen();
procedure ByeScreen();
procedure ShowMap(m: map);

procedure DrawMainMenu(m: map);
procedure DrawProfileMenu(m: map; p: profile; c: cars);
procedure DrawTradeMenu(m: map; p: profile; c: cars; event: gameevent;
                        tl: tradelist; choise: integer);
procedure DrawShopMenu(m: map; p: profile; price: longint);
procedure DrawCasinoMenu(m: map; p: profile; status: integer);

implementation
uses crt, slib, engine;

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

procedure DrawMainMenu(m: map);
var
    x, y: integer;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - length('1) Profile')) div 2;
    y := (ScreenHeight - 5) div 2;
    GotoXY(x, y);
    write('1) Profile');

    y += 1;
    GotoXY(x, y);
    write('2) Market');

    y += 1;
    GotoXY(x, y);
    write('3) Shop');

    y += 1;
    GotoXY(x, y);
    write('4) Casino');

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
    x := (ScreenWidth - length('Profile')) div 2;
    y := (ScreenHeight - 14) div 2;
    GotoXY(x, y);
    write('Profile');

    x := (ScreenWidth - (length('Money: ') + length(IrS(p.m)))) div 2;
    y += 3;
    GotoXY(x, y);
    write('Money: ', p.m);

    x := (ScreenWidth - length('Garage:')) div 2;
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
            tmpcar := SearchCarByIdx(c, p.c[i]);
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

procedure DrawTradeMenu(m: map; p: profile; c: cars; event: gameevent;
                        tl: tradelist; choise: integer);
var
    x, y, i: integer;
    tmpcar: gamecar;
begin
    clrscr;
    if (choise = 0) and (event.idx <> 0) then
    begin
        x := (ScreenWidth - length(event.sit)) div 2;
        y := (ScreenHeight - 2) div 2;
        GotoXY(x, y);
        write(event.sit);
        x := (ScreenWidth - length(event.msg)) div 2;
        y += 1;
        GotoXY(x, y);
        write(event.msg);
        delay(2000);
        clrscr;
    end;
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
        tmpcar := SearchCarByIdx(c, tl[i].idx);
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

procedure DrawShopMenu(m: map; p: profile; price: longint);
var
    x, y: integer;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - length('Shop')) div 2;
    y := (ScreenHeight - 14) div 2;
    GotoXY(x, y);
    write('Shop');

    y += 3;
    if p.s <> 5 then
    begin
        x := (ScreenWidth - 16 - length(IrS(price))) div 2;
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

procedure DrawCasinoMenu(m: map; p: profile; status: integer);
var
    x, y: integer;
begin
    clrscr;
    ShowMap(m);
    x := (ScreenWidth - length('Casino')) div 2;
    y := (ScreenHeight - 14) div 2;
    GotoXY(x, y);
    write('Casino');

    x := (ScreenWidth - length('Money: ') - length(IrS(p.m))) div 2;
    y += 3;
    GotoXY(x, y);
    write('Money: ', p.m);

    case status of
        0:
        begin
            x := (ScreenWidth - length('R) Red')-4) div 2;
            y += 3;
            GotoXY(x, y);
            write('R) Red');

            y += 1;
            GotoXY(x, y);
            write('B) Blue');

            x := (ScreenWidth - length('Choose:')) div 2;
            y += 3;
            GotoXY(x, y);
            write('Choose:');
        end;
        1:
        begin
            x := (ScreenWidth - length('5) 1000000')) div 2;
            y += 3;
            GotoXY(x, y);
            write('1) 50000');

            y += 1;
            GotoXY(x, y);
            write('2) 100000');

            y += 1;
            GotoXY(x, y);
            write('3) 250000');

            y += 1;
            GotoXY(x, y);
            write('4) 500000');

            y += 1;
            GotoXY(x, y);
            write('5) 1000000');

            x := (ScreenWidth - length('Choose:')) div 2;
            y += 2;
            GotoXY(x, y);
            write('Choose:');
            x := (ScreenWidth - length('Not enough money')) div 2;
            y += 1;
            GotoXY(x, y);
        end;
        2:
        begin
            GotoXY((ScreenWidth - 8) div 2, ScreenHeight div 2);
            write('You win!');
        end;
        3:
        begin
            GotoXY((ScreenWidth - 9) div 2, ScreenHeight div 2);
            write('You lose.');
        end;
    end;
end;

end.
