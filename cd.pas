program CarDealer;
uses
    crt,
    slib in 'lib/slib.pp',
    datstrc in 'lib/datstrc.pp',
    infc in 'lib/infc.pp',
    engine in 'lib/engine.pp';
    
var
    m: map;
    p: profile;
    c: cars;
    e: events;
    ch: char;
begin
    Init(m, p, c, e);
    while true do
    begin
        DrawMainMenu(m);
        repeat
            ch := ReadKey;
        until ch in ['1', '2', '3', '4', 'n', 'N', 'q', 'Q'];
        case ch of
            '1': ProfileMenu(m, p, c);
            '2': TradeMenu(m, p, c, e);
            '3': ShopMenu(m, p);
            '4': CasinoMenu(m, p);
            'n', 'N':
            begin
                CreateProfile;
                ParseProfile(p);
            end;
            'q', 'Q': ByeScreen;
        end;
    end;
end.
