unit datstrc;
interface
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
        idx: integer;
        brand: string;
        model: string;
        lux: integer;
        price: longint;
        next: cars;
    end;

    events = ^gameevent;
    gameevent = record
        idx: integer;
        brand: string;
        oper: char;
        diff: longint;
        per: integer; { percentage }
        sit: string; { situation }
        msg: string; { message } 
        next: events;
    end;

    tradelistelement = record
        idx: integer;
        price: longint;
    end;
    tradelist = array [1..5] of tradelistelement;

    color = (r, b);

implementation
end.
